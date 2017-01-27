require 'spec_helper'

RSpec.describe RSpecJsonMatchers::AbsenceMatcher do
  # See `spec/json_matchers/absence_matcher_objects.rb` for matcher definitions

  let(:valid_hash) { {} }
  let(:invalid_hash) { { absent: :not_absent } }

  it 'matches absent keys' do
    expect(valid_hash).to match_api_response(a_serialized_absent)
  end

  it 'detects a non-absent key' do
    expect(invalid_hash).to_not be_a_serialized_absent
  end
end
