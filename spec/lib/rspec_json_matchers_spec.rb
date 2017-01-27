require 'spec_helper'

RSpec.describe RSpecJsonMatchers do
  # See `spec/json_matchers/rspec_json_matchers_objects.rb` for matcher
  # definitions

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
      'another_matcher' => {
        'foo' => 'bar'
      }
    }
  end

  let(:serialized_another_object) { { 'foo' => 'bar' } }

  let(:invalid_hash) { { absent: :not_absent } }

  it 'matches absent keys' do
    expect(valid_hash).to match_api_response(a_serialized_matcher_test_object)
  end

  it 'detects a non-absent key' do
    expect(invalid_hash).to_not be_a_serialized_matcher_test_object
  end
end
