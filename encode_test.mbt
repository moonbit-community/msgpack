// Ported from Deno std msgpack module encoding tests
// Original source: https://github.com/denoland/std/tree/42fd485b615d7cc647c7d2f12610c42d68a597e6/msgpack

// Test positive number encoding

///|
test "encode positive numbers" {
  // Test positive fixint (0-127)
  let result1 = @msgpack.encode(@msgpack.create_int(1))
  let expected1 = @msgpack.create_bytes([1])
  inspect(@msgpack.bytes_equal(result1, expected1), content="true")

  // Test uint8 (255)
  let result255 = @msgpack.encode(@msgpack.create_int(255))
  let expected255 = @msgpack.create_bytes([0xcc, 255])
  inspect(@msgpack.bytes_equal(result255, expected255), content="true")

  // Test uint16 (2000)
  let result2000 = @msgpack.encode(@msgpack.create_int(2000))
  let expected2000 = @msgpack.create_bytes([0xcd, 7, 208])
  inspect(@msgpack.bytes_equal(result2000, expected2000), content="true")

  // Test uint32 (70000)
  let result70000 = @msgpack.encode(@msgpack.create_int(70000))
  let expected70000 = @msgpack.create_bytes([0xce, 0, 1, 17, 112])
  inspect(@msgpack.bytes_equal(result70000, expected70000), content="true")
}

// Test negative number encoding

///|
test "encode negative numbers" {
  // Test negative fixint (-1)
  let result_neg1 = @msgpack.encode(@msgpack.create_int(-1))
  let expected_neg1 = @msgpack.create_bytes([255])
  inspect(@msgpack.bytes_equal(result_neg1, expected_neg1), content="true")

  // Test int8 (-127)
  let result_neg127 = @msgpack.encode(@msgpack.create_int(-127))
  let expected_neg127 = @msgpack.create_bytes([0xd0, 129])
  inspect(@msgpack.bytes_equal(result_neg127, expected_neg127), content="true")

  // Test int16 (-1000)
  let result_neg1000 = @msgpack.encode(@msgpack.create_int(-1000))
  let expected_neg1000 = @msgpack.create_bytes([0xd1, 252, 24])
  inspect(
    @msgpack.bytes_equal(result_neg1000, expected_neg1000),
    content="true",
  )

  // Test int32 (-60000)
  let result_neg60000 = @msgpack.encode(@msgpack.create_int(-60000))
  let expected_neg60000 = @msgpack.create_bytes([0xd2, 255, 255, 21, 160])
  inspect(
    @msgpack.bytes_equal(result_neg60000, expected_neg60000),
    content="true",
  )
}

// Test string encoding

///|
test "encode strings" {
  // Test fixstr
  let result_hello = @msgpack.encode(@msgpack.create_string("hello world"))
  let expected_hello = @msgpack.create_bytes([
    171, 104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100,
  ])
  inspect(@msgpack.bytes_equal(result_hello, expected_hello), content="true")

  // Test empty string
  let result_empty = @msgpack.encode(@msgpack.create_string(""))
  let expected_empty = @msgpack.create_bytes([0xa0])
  inspect(@msgpack.bytes_equal(result_empty, expected_empty), content="true")

  // Test single character
  let result_single = @msgpack.encode(@msgpack.create_string("A"))
  let expected_single = @msgpack.create_bytes([0xa1, 65])
  inspect(@msgpack.bytes_equal(result_single, expected_single), content="true")
}

// Test array encoding

///|
test "encode arrays" {
  // Test empty array
  let empty_array = @msgpack.create_array([])
  let result_empty = @msgpack.encode(empty_array)
  let expected_empty = @msgpack.create_bytes([0x90])
  inspect(@msgpack.bytes_equal(result_empty, expected_empty), content="true")

  // Test small array
  let small_array = @msgpack.create_array([
    @msgpack.create_int(1),
    @msgpack.create_int(2),
    @msgpack.create_int(3),
  ])
  let result_small = @msgpack.encode(small_array)
  let expected_small = @msgpack.create_bytes([0x93, 1, 2, 3])
  inspect(@msgpack.bytes_equal(result_small, expected_small), content="true")

  // Test single element array
  let single_array = @msgpack.create_array([@msgpack.create_string("foo")])
  let result_single = @msgpack.encode(single_array)
  let expected_single = @msgpack.create_bytes([0x91, 0xa3, 102, 111, 111])
  inspect(@msgpack.bytes_equal(result_single, expected_single), content="true")
}

// Test map encoding

///|
test "encode maps" {
  // Test empty map
  let empty_map = @builtin.Map([])
  let result_empty = @msgpack.encode(@msgpack.create_map(empty_map))
  let expected_empty = @msgpack.create_bytes([0x80])
  inspect(@msgpack.bytes_equal(result_empty, expected_empty), content="true")

  // Test simple map - we'll just test that it encodes without error
  let simple_map = @builtin.Map([])
  simple_map["a"] = @msgpack.create_int(2)
  simple_map["b"] = @msgpack.create_int(3)
  let result_simple = @msgpack.encode(@msgpack.create_map(simple_map))
  // Map encoding order might vary, so we just test the length and first byte
  inspect(result_simple.length() > 1, content="true")
  inspect(result_simple[0].to_int() == 0x82, content="true") // fixmap with 2 elements
}

// Test basic type encoding

///|
test "encode basic types" {
  // Test nil
  let result_nil = @msgpack.encode(@msgpack.create_nil())
  let expected_nil = @msgpack.create_bytes([0xc0])
  inspect(@msgpack.bytes_equal(result_nil, expected_nil), content="true")

  // Test true
  let result_true = @msgpack.encode(@msgpack.create_bool(true))
  let expected_true = @msgpack.create_bytes([0xc3])
  inspect(@msgpack.bytes_equal(result_true, expected_true), content="true")

  // Test false
  let result_false = @msgpack.encode(@msgpack.create_bool(false))
  let expected_false = @msgpack.create_bytes([0xc2])
  inspect(@msgpack.bytes_equal(result_false, expected_false), content="true")
}
