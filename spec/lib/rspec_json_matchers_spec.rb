require 'spec_helper'

RSpec.describe RSpecJsonMatchers do
  RSpecJsonMatchers.define_api_matcher :test_object do
    numeric_type { a_kind_of(Integer) }
    string_type { an_instance_of(String) }
    numeric_value { numeric_value }
    string_value { string_value }
    absent_value { absent }
    nil_value { a_nil_value }
    composed_matcher { a_nil_value.or(an_instance_of(String)) }
    another_matcher { a_serialized_another_object }
  end

  RSpecJsonMatchers.define_api_matcher :another_object do
    foo { an_instance_of(String) }
  end

  let(:string_value) { 'bar' }
  let(:numeric_value) { 2 }

  let(:valid_hash) do
    {
      'numeric_type' => 1,
      'string_type' => 'foo',
      'numeric_value' => numeric_value,
      'string_value' => string_value,
      # absent_value
      'nil_value' => nil,
      'composed_matcher' => 'not nil but can be nil',
      'another_matcher' => serialized_another_object
    }
  end

  let(:serialized_another_object) { { 'foo' => 'bar' } }

  let(:invalid_hash) { { absent: :not_absent } }

  it 'matches absent keys' do
    expect(valid_hash).to match_api_response(a_serialized_test_object)
  end

  it 'detects a non-absent key' do
    expect(invalid_hash).to_not be_a_serialized_test_object
  end
end
