// MessagePack library demo

///|
fn main {
  println("=== MoonBit MessagePack Library Demo ===")

  // Create some test values
  let nil_val = @msgpack.create_nil()
  let bool_val = @msgpack.create_bool(true)
  let int_val = @msgpack.create_int(42)
  let str_val = @msgpack.create_string("hello")
  println("\n1. Encoding test values:")

  // Encode values
  let nil_encoded = @msgpack.encode(nil_val)
  let bool_encoded = @msgpack.encode(bool_val)
  let int_encoded = @msgpack.encode(int_val)
  let str_encoded = @msgpack.encode(str_val)
  println("Nil encoded to \{nil_encoded.length()} bytes")
  println("Bool(true) encoded to \{bool_encoded.length()} bytes")
  println("Int(42) encoded to \{int_encoded.length()} bytes")
  println("String(\"hello\") encoded to \{str_encoded.length()} bytes")
  println("\n2. Testing decoding:")

  // Test decoding with manually created byte arrays
  let nil_test_data = Bytes::from_array([(0xc0 : Int).to_byte()])
  let bool_test_data = Bytes::from_array([(0xc3 : Int).to_byte()])
  let int_test_data = Bytes::from_array([(42 : Int).to_byte()])
  match @msgpack.decode(nil_test_data) {
    Ok(@msgpack.Nil) => println("✓ Nil decoded successfully")
    Ok(_) => println("✗ Nil decoded to wrong type")
    Err(e) => println("✗ Nil decode error: " + e.to_string())
  }
  match @msgpack.decode(bool_test_data) {
    Ok(@msgpack.Bool(true)) => println("✓ Bool(true) decoded successfully")
    Ok(_) => println("✗ Bool(true) decoded to wrong value")
    Err(e) => println("✗ Bool(true) decode error: " + e.to_string())
  }
  match @msgpack.decode(int_test_data) {
    Ok(@msgpack.Int(42)) => println("✓ Int(42) decoded successfully")
    Ok(_) => println("✗ Int(42) decoded to wrong value")
    Err(e) => println("✗ Int(42) decode error: " + e.to_string())
  }
  println("\n3. Round-trip test:")

  // Test round-trip encoding/decoding
  match @msgpack.decode(nil_encoded) {
    Ok(@msgpack.Nil) => println("✓ Nil round-trip successful")
    Ok(_) => println("✗ Nil round-trip failed: wrong type")
    Err(e) => println("✗ Nil round-trip failed: " + e.to_string())
  }
  match @msgpack.decode(bool_encoded) {
    Ok(@msgpack.Bool(true)) => println("✓ Bool(true) round-trip successful")
    Ok(_) => println("✗ Bool(true) round-trip failed: wrong value")
    Err(e) => println("✗ Bool(true) round-trip failed: " + e.to_string())
  }
  match @msgpack.decode(int_encoded) {
    Ok(@msgpack.Int(42)) => println("✓ Int(42) round-trip successful")
    Ok(_) => println("✗ Int(42) round-trip failed: wrong value")
    Err(e) => println("✗ Int(42) round-trip failed: " + e.to_string())
  }

  println("\n=== Demo Complete ===")
  println("MessagePack library successfully demonstrates basic functionality!")
}
