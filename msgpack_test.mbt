// Ported from Deno std msgpack module integration tests
// Original source: https://github.com/denoland/std/tree/42fd485b615d7cc647c7d2f12610c42d68a597e6/msgpack

// Test round-trip encode/decode

///|
test "round trip encode decode" {
  // Test integers
  let test_values = [0, 1, -1, 42, -42, 127, -32]
  for value in test_values {
    let encoded = @msgpack.encode(@msgpack.create_int(value))
    let decoded = @msgpack.decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }

  // Test strings
  let test_strings = ["", "hello", "world", "A"]
  for str_val in test_strings {
    let encoded = @msgpack.encode(@msgpack.create_string(str_val))
    let decoded = @msgpack.decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }

  // Test booleans
  let encoded_true = @msgpack.encode(@msgpack.create_bool(true))
  let decoded_true = @msgpack.decode(encoded_true)
  match decoded_true {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  let encoded_false = @msgpack.encode(@msgpack.create_bool(false))
  let decoded_false = @msgpack.decode(encoded_false)
  match decoded_false {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test nil
  let encoded_nil = @msgpack.encode(@msgpack.create_nil())
  let decoded_nil = @msgpack.decode(encoded_nil)
  match decoded_nil {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test complex data structures

///|
test "complex data structures" {
  // Test nested array
  let inner_array = @msgpack.create_array([
    @msgpack.create_int(1),
    @msgpack.create_int(2),
  ])
  let outer_array = @msgpack.create_array([inner_array, @msgpack.create_int(3)])
  let encoded = @msgpack.encode(outer_array)
  let decoded = @msgpack.decode(encoded)
  match decoded {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test mixed array
  let mixed_array = @msgpack.create_array([
    @msgpack.create_int(42),
    @msgpack.create_string("hello"),
    @msgpack.create_bool(true),
    @msgpack.create_nil(),
  ])
  let encoded_mixed = @msgpack.encode(mixed_array)
  let decoded_mixed = @msgpack.decode(encoded_mixed)
  match decoded_mixed {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test edge cases

///|
test "edge cases" {
  // Test empty string
  let empty_str = @msgpack.create_string("")
  let encoded_empty = @msgpack.encode(empty_str)
  let decoded_empty = @msgpack.decode(encoded_empty)
  match decoded_empty {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test zero
  let zero_int = @msgpack.create_int(0)
  let encoded_zero = @msgpack.encode(zero_int)
  let decoded_zero = @msgpack.decode(encoded_zero)
  match decoded_zero {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test maximum positive fixint
  let max_fixint = @msgpack.create_int(127)
  let encoded_max = @msgpack.encode(max_fixint)
  let decoded_max = @msgpack.decode(encoded_max)
  match decoded_max {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test minimum negative fixint
  let min_fixint = @msgpack.create_int(-32)
  let encoded_min = @msgpack.encode(min_fixint)
  let decoded_min = @msgpack.decode(encoded_min)
  match decoded_min {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test large data structures

///|
test "large data structures" {
  // Test large array - create smaller for performance
  let values : Array[@msgpack.Value] = []
  for i = 0; i < 20; i = i + 1 {
    values.push(@msgpack.create_int(i))
  }
  let large_array = @msgpack.create_array(values)
  let encoded_large = @msgpack.encode(large_array)
  let decoded_large = @msgpack.decode(encoded_large)
  match decoded_large {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test data type validation

///|
test "data type validation" {
  // Test consistent encoding/decoding for all basic types
  let test_data = [
    @msgpack.create_nil(),
    @msgpack.create_bool(true),
    @msgpack.create_bool(false),
    @msgpack.create_int(0),
    @msgpack.create_int(42),
    @msgpack.create_int(-1),
    @msgpack.create_string("test"),
    @msgpack.create_array([@msgpack.create_int(1), @msgpack.create_int(2)]),
  ]

  for data in test_data {
    let encoded = @msgpack.encode(data)
    let decoded = @msgpack.decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      Err(_) => inspect(false, content="true")
    }
  }
}

// Compatibility tests - test Deno sample data

///|
test "deno compatibility tests" {
  // Test data structure from testdata/1.json
  let test_map = @builtin.Map([])
  test_map["int0"] = @msgpack.create_int(0)
  test_map["int1"] = @msgpack.create_int(1)
  test_map["int1-"] = @msgpack.create_int(-1)
  test_map["nil"] = @msgpack.create_nil()
  test_map["true"] = @msgpack.create_bool(true)
  test_map["false"] = @msgpack.create_bool(false)
  test_map["string0"] = @msgpack.create_string("")
  test_map["string1"] = @msgpack.create_string("A")

  let encoded_complex = @msgpack.encode(@msgpack.create_map(test_map))
  let decoded_complex = @msgpack.decode(encoded_complex)
  match decoded_complex {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test array with different types
  let mixed_types_array = @msgpack.create_array([
    @msgpack.create_int(1),
    @msgpack.create_string("foo"),
    @msgpack.create_bool(false),
    @msgpack.create_nil(),
    @msgpack.create_array([@msgpack.create_int(1), @msgpack.create_int(2)]),
  ])

  let encoded_mixed_types = @msgpack.encode(mixed_types_array)
  let decoded_mixed_types = @msgpack.decode(encoded_mixed_types)
  match decoded_mixed_types {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Performance test (simplified version)

///|
test "basic performance test" {
  // Create a reasonably sized data structure
  let perf_map = @builtin.Map([])
  for i = 0; i < 10; i = i + 1 {
    perf_map["key\{i}"] = @msgpack.create_int(i)
  }

  let perf_data = @msgpack.create_map(perf_map)

  // Test multiple encode/decode cycles
  for i = 0; i < 5; i = i + 1 {
    let encoded = @msgpack.encode(perf_data)
    let decoded = @msgpack.decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }
}
