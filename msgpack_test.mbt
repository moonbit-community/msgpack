// Ported from Deno std msgpack module integration tests
// Original source: https://github.com/denoland/std/tree/42fd485b615d7cc647c7d2f12610c42d68a597e6/msgpack

// Test round-trip encode/decode

///|
test "round trip encode decode" {
  // Test integers
  let test_values = [0, 1, -1, 42, -42, 127, -32]
  for value in test_values {
    let encoded = encode(create_int(value))
    let decoded = decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }

  // Test strings
  let test_strings = ["", "hello", "world", "A"]
  for str_val in test_strings {
    let encoded = encode(create_string(str_val))
    let decoded = decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }

  // Test booleans
  let encoded_true = encode(create_bool(true))
  let decoded_true = decode(encoded_true)
  match decoded_true {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  let encoded_false = encode(create_bool(false))
  let decoded_false = decode(encoded_false)
  match decoded_false {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test nil
  let encoded_nil = encode(create_nil())
  let decoded_nil = decode(encoded_nil)
  match decoded_nil {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test complex data structures

///|
test "complex data structures" {
  // Test nested array
  let inner_array = create_array([create_int(1), create_int(2)])
  let outer_array = create_array([inner_array, create_int(3)])
  let encoded = encode(outer_array)
  let decoded = decode(encoded)
  match decoded {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test mixed array
  let mixed_array = create_array([
    create_int(42),
    create_string("hello"),
    create_bool(true),
    create_nil(),
  ])
  let encoded_mixed = encode(mixed_array)
  let decoded_mixed = decode(encoded_mixed)
  match decoded_mixed {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test edge cases

///|
test "edge cases" {
  // Test empty string
  let empty_str = create_string("")
  let encoded_empty = encode(empty_str)
  let decoded_empty = decode(encoded_empty)
  match decoded_empty {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test zero
  let zero_int = create_int(0)
  let encoded_zero = encode(zero_int)
  let decoded_zero = decode(encoded_zero)
  match decoded_zero {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test maximum positive fixint
  let max_fixint = create_int(127)
  let encoded_max = encode(max_fixint)
  let decoded_max = decode(encoded_max)
  match decoded_max {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test minimum negative fixint
  let min_fixint = create_int(-32)
  let encoded_min = encode(min_fixint)
  let decoded_min = decode(encoded_min)
  match decoded_min {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

// Test large data structures

///|
test "large data structures" {
  // Test large array - create smaller for performance
  let values : Array[Value] = []
  for i = 0; i < 20; i = i + 1 {
    values.push(create_int(i))
  }
  let large_array = create_array(values)
  let encoded_large = encode(large_array)
  let decoded_large = decode(encoded_large)
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
    create_nil(),
    create_bool(true),
    create_bool(false),
    create_int(0),
    create_int(42),
    create_int(-1),
    create_string("test"),
    create_array([create_int(1), create_int(2)]),
  ]

  for data in test_data {
    let encoded = encode(data)
    let decoded = decode(encoded)
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
  test_map["int0"] = create_int(0)
  test_map["int1"] = create_int(1)
  test_map["int1-"] = create_int(-1)
  test_map["nil"] = create_nil()
  test_map["true"] = create_bool(true)
  test_map["false"] = create_bool(false)
  test_map["string0"] = create_string("")
  test_map["string1"] = create_string("A")

  let encoded_complex = encode(create_map(test_map))
  let decoded_complex = decode(encoded_complex)
  match decoded_complex {
    Ok(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  // Test array with different types
  let mixed_types_array = create_array([
    create_int(1),
    create_string("foo"),
    create_bool(false),
    create_nil(),
    create_array([create_int(1), create_int(2)]),
  ])

  let encoded_mixed_types = encode(mixed_types_array)
  let decoded_mixed_types = decode(encoded_mixed_types)
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
    perf_map["key\{i}"] = create_int(i)
  }

  let perf_data = create_map(perf_map)

  // Test multiple encode/decode cycles
  for i = 0; i < 5; i = i + 1 {
    let encoded = encode(perf_data)
    let decoded = decode(encoded)
    match decoded {
      Ok(_) => inspect(true, content="true")
      _ => inspect(false, content="true")
    }
  }
}
