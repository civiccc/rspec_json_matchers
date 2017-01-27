puts :doing_this

RSpecJsonMatchers.define_api_matcher :matcher_test_object do
  numeric_type { a_kind_of(Integer) }
  string_type { an_instance_of(String) }
  numeric_value { numeric_value }
  string_value { string_value }
  absent_value { absent }
  nil_value { a_nil_value }
  composed_matcher { a_nil_value.or(an_instance_of(String)) }
  another_matcher { a_serialized_matcher_another_object }
end

RSpecJsonMatchers.define_api_matcher :matcher_another_object do
  foo { an_instance_of(String) }
end
