// MessagePack decoder

// Simple decoder - returns Result type for error handling

///|
pub fn decode(data : Bytes) -> Result[Value, MsgPackError] {
  if data.length() == 0 {
    return Err(InvalidData("Empty data"))
  }
  let first_byte = data[0]
  match first_byte.to_int() {
    0xc0 => Ok(Nil)
    0xc2 => Ok(Bool(false))
    0xc3 => Ok(Bool(true))
    0xcc => {
      // uint8
      if data.length() < 2 {
        return Err(InvalidData("Incomplete uint8"))
      }
      Ok(Int(data[1].to_int()))
    }
    0xcd => {
      // uint16
      if data.length() < 3 {
        return Err(InvalidData("Incomplete uint16"))
      }
      let value = (data[1].to_int() << 8) | data[2].to_int()
      Ok(Int(value))
    }
    0xce => {
      // uint32
      if data.length() < 5 {
        return Err(InvalidData("Incomplete uint32"))
      }
      let value = (data[1].to_int() << 24) |
        (data[2].to_int() << 16) |
        (data[3].to_int() << 8) |
        data[4].to_int()
      Ok(Int(value))
    }
    0xd0 => {
      // int8
      if data.length() < 2 {
        return Err(InvalidData("Incomplete int8"))
      }
      let value = data[1].to_int()
      let signed_value = if value > 127 { value - 256 } else { value }
      Ok(Int(signed_value))
    }
    0xd1 => {
      // int16
      if data.length() < 3 {
        return Err(InvalidData("Incomplete int16"))
      }
      let value = (data[1].to_int() << 8) | data[2].to_int()
      let signed_value = if value > 32767 { value - 65536 } else { value }
      Ok(Int(signed_value))
    }
    0xd2 => {
      // int32
      if data.length() < 5 {
        return Err(InvalidData("Incomplete int32"))
      }
      let value = (data[1].to_int() << 24) |
        (data[2].to_int() << 16) |
        (data[3].to_int() << 8) |
        data[4].to_int()
      // For 32-bit signed integers, we need to handle the sign bit
      // Note: MoonBit's Int type limitations require simplified handling
      let signed_value = value
      Ok(Int(signed_value))
    }
    0xdc => {
      // array16
      if data.length() < 3 {
        return Err(InvalidData("Incomplete array16"))
      }
      let array_length = (data[1].to_int() << 8) | data[2].to_int()
      match decode_array(data, 3, array_length) {
        Ok((value, _)) => Ok(value)
        Err(e) => Err(e)
      }
    }
    0xde => {
      // map16
      if data.length() < 3 {
        return Err(InvalidData("Incomplete map16"))
      }
      let map_length = (data[1].to_int() << 8) | data[2].to_int()
      match decode_map(data, 3, map_length) {
        Ok((value, _)) => Ok(value)
        Err(e) => Err(e)
      }
    }
    _ =>
      if (first_byte.to_int() & 0x80) == 0 {
        // positive fixint
        Ok(Int(first_byte.to_int()))
      } else if (first_byte.to_int() & 0xe0) == 0xe0 {
        // negative fixint
        Ok(Int(first_byte.to_int() - 256)) // Convert to negative
      } else if (first_byte.to_int() & 0xf0) == 0xa0 {
        // fixstr
        let str_length = first_byte.to_int() & 0x1f
        if data.length() < str_length + 1 {
          return Err(InvalidData("Incomplete fixstr"))
        }
        let str_bytes : Array[Byte] = []
        for i = 1; i <= str_length; i = i + 1 {
          str_bytes.push(data[i])
        }
        // Simplified string conversion - MoonBit handles UTF-8 automatically
        let mut str_val = ""
        // For now, create a simple string from bytes
        for byte in str_bytes {
          let char_val = Int::unsafe_to_char(byte.to_int())
          str_val = str_val + char_val.to_string()
        }
        Ok(String(str_val))
      } else if (first_byte.to_int() & 0xf0) == 0x90 {
        // fixarray
        let array_length = first_byte.to_int() & 0x0f
        match decode_array(data, 1, array_length) {
          Ok((value, _)) => Ok(value)
          Err(e) => Err(e)
        }
      } else if (first_byte.to_int() & 0xf0) == 0x80 {
        // fixmap
        let map_length = first_byte.to_int() & 0x0f
        match decode_map(data, 1, map_length) {
          Ok((value, _)) => Ok(value)
          Err(e) => Err(e)
        }
      } else {
        Err(InvalidData("Unsupported format"))
      }
  }
}

// Helper functions for decoding complex types

///|
fn decode_array(
  data : Bytes,
  start_offset : Int,
  length : Int,
) -> Result[(Value, Int), MsgPackError] {
  let array : Array[Value] = []
  let mut offset = start_offset
  for i = 0; i < length; i = i + 1 {
    if offset >= data.length() {
      return Err(InvalidData("Incomplete array data"))
    }
    match decode_value_at_offset(data, offset) {
      Ok((value, new_offset)) => {
        array.push(value)
        offset = new_offset
      }
      Err(e) => return Err(e)
    }
  }
  Ok((Array(array), offset))
}

///|
fn decode_map(
  data : Bytes,
  start_offset : Int,
  length : Int,
) -> Result[(Value, Int), MsgPackError] {
  let map = @builtin.Map([])
  let mut offset = start_offset
  for i = 0; i < length; i = i + 1 {
    if offset >= data.length() {
      return Err(InvalidData("Incomplete map data"))
    }
    // Decode key
    match decode_value_at_offset(data, offset) {
      Ok((key_value, new_offset1)) => {
        offset = new_offset1
        match key_value {
          String(key) =>
            // Decode value
            match decode_value_at_offset(data, offset) {
              Ok((value, new_offset2)) => {
                map[key] = value
                offset = new_offset2
              }
              Err(e) => return Err(e)
            }
          _ => return Err(InvalidData("Map key must be string"))
        }
      }
      Err(e) => return Err(e)
    }
  }
  Ok((Map(map), offset))
}

///|
fn decode_value_at_offset(
  data : Bytes,
  offset : Int,
) -> Result[(Value, Int), MsgPackError] {
  if offset >= data.length() {
    return Err(InvalidData("Offset out of bounds"))
  }

  let first_byte = data[offset]
  match first_byte.to_int() {
    0xc0 => Ok((Nil, offset + 1))
    0xc2 => Ok((Bool(false), offset + 1))
    0xc3 => Ok((Bool(true), offset + 1))
    0xcc => {
      // uint8
      if offset + 1 >= data.length() {
        return Err(InvalidData("Incomplete uint8"))
      }
      Ok((Int(data[offset + 1].to_int()), offset + 2))
    }
    0xcd => {
      // uint16
      if offset + 2 >= data.length() {
        return Err(InvalidData("Incomplete uint16"))
      }
      let value = (data[offset + 1].to_int() << 8) | data[offset + 2].to_int()
      Ok((Int(value), offset + 3))
    }
    0xce => {
      // uint32
      if offset + 4 >= data.length() {
        return Err(InvalidData("Incomplete uint32"))
      }
      let value = (data[offset + 1].to_int() << 24) |
        (data[offset + 2].to_int() << 16) |
        (data[offset + 3].to_int() << 8) |
        data[offset + 4].to_int()
      Ok((Int(value), offset + 5))
    }
    0xdc => {
      // array16
      if offset + 2 >= data.length() {
        return Err(InvalidData("Incomplete array16"))
      }
      let array_length = (data[offset + 1].to_int() << 8) |
        data[offset + 2].to_int()
      decode_array(data, offset + 3, array_length)
    }
    0xde => {
      // map16
      if offset + 2 >= data.length() {
        return Err(InvalidData("Incomplete map16"))
      }
      let map_length = (data[offset + 1].to_int() << 8) |
        data[offset + 2].to_int()
      decode_map(data, offset + 3, map_length)
    }
    0xd0 => {
      // int8
      if offset + 1 >= data.length() {
        return Err(InvalidData("Incomplete int8"))
      }
      let value = data[offset + 1].to_int()
      let signed_value = if value > 127 { value - 256 } else { value }
      Ok((Int(signed_value), offset + 2))
    }
    0xd1 => {
      // int16
      if offset + 2 >= data.length() {
        return Err(InvalidData("Incomplete int16"))
      }
      let value = (data[offset + 1].to_int() << 8) | data[offset + 2].to_int()
      let signed_value = if value > 32767 { value - 65536 } else { value }
      Ok((Int(signed_value), offset + 3))
    }
    0xd2 => {
      // int32
      if offset + 4 >= data.length() {
        return Err(InvalidData("Incomplete int32"))
      }
      let value = (data[offset + 1].to_int() << 24) |
        (data[offset + 2].to_int() << 16) |
        (data[offset + 3].to_int() << 8) |
        data[offset + 4].to_int()
      Ok((Int(value), offset + 5))
    }
    _ =>
      if (first_byte.to_int() & 0x80) == 0 {
        // positive fixint
        Ok((Int(first_byte.to_int()), offset + 1))
      } else if (first_byte.to_int() & 0xe0) == 0xe0 {
        // negative fixint
        Ok((Int(first_byte.to_int() - 256), offset + 1))
      } else if (first_byte.to_int() & 0xf0) == 0xa0 {
        // fixstr
        let str_length = first_byte.to_int() & 0x1f
        if offset + str_length >= data.length() {
          return Err(InvalidData("Incomplete fixstr"))
        }
        let str_bytes : Array[Byte] = []
        for i = 1; i <= str_length; i = i + 1 {
          str_bytes.push(data[offset + i])
        }
        let mut str_val = ""
        for byte in str_bytes {
          let char_val = Int::unsafe_to_char(byte.to_int())
          str_val = str_val + char_val.to_string()
        }
        Ok((String(str_val), offset + str_length + 1))
      } else if (first_byte.to_int() & 0xf0) == 0x90 {
        // fixarray
        let array_length = first_byte.to_int() & 0x0f
        decode_array(data, offset + 1, array_length)
      } else if (first_byte.to_int() & 0xf0) == 0x80 {
        // fixmap
        let map_length = first_byte.to_int() & 0x0f
        decode_map(data, offset + 1, map_length)
      } else {
        Err(InvalidData("Unsupported format"))
      }
  }
}
