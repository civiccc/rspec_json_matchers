require 'rspec_json_matchers/json_matcher_definition'
require 'rspec_json_matchers/api_response_matcher'
require 'rspec_json_matchers/fuzzy_matcher'
require 'rspec_json_matchers/absence_matcher'

require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/keys'

# This module defines matchers that are useful in writing request specs for our
# API. Specifically, they make it easy to specify the structure of the entire
# response, taking advantage of the fact that our API is mostly made up of
# objects that should be consistent in their structure anywhere that they
# appear.
#
# For example, a "profile" is a type of API object that has the same structure
# whether it's appearing in the author field of a comment or the profile field
# of the /me endpoint. We can use the `define_api_matcher` method to define
# matchers called `a_serialized_profile` and `be_a_serialized_profile` which
# will match successfully against any serialized profile. If the user passes a
# hash into the matcher, they can customize it by specifying specific values it
# should include or using any RSpec matcher to narrow down the range of
# acceptable values for a given field. They can also use the `absent`
# matcher to assert that a given key should *not* be included in the response.
#
# @see spec/api_matchers/profile.rb for an example of an API matcher.
module RSpecJsonMatchers
  # @param [Symbol]
  # @yield [] declarations for expected fields and matcher pairs
  def self.define_api_matcher(name, &block)
    definition = JsonMatcherDefinition.new
    definition.instance_eval(&block)

    # @param [expected] a hash of values/matchers with which to customize this
    #   API matcher instance.
    # @return [ApiResponseMatcher] a matcher based on the provided name,
    #   definition block, and hash of expected values/matchers.
    define_method "a_serialized_#{name}" do |expected = {}|
      ApiResponseMatcher.new(
        expected,
        object_definition: definition,
        object_name: name.to_s,
        context: self
      )
    end
    alias_method "be_a_serialized_#{name}", "a_serialized_#{name}"
  end

  # This matcher validates all or part of an API response against a schema. If
  # the response violates the schema, it shows which parts of the response
  # failed to match our expectations.
  # @param expected [Hash] a hash representing an API response. Its values can
  #   be matchers (like `an_instance_of(String)`) or concrete values (like
  #   `10`).
  # @return [ApiResponseMatcher]
  def match_api_response(expected)
    ApiResponseMatcher.new(expected)
  end
  alias_method 'a_hash_matching_api_response', 'match_api_response'

  # This matcher works like `match_api_response`, but also verifies that
  # response matches `meta: a_serialized_pagination_metadata_hash`. This
  # prevents that line from needing to be repeated in every spec of a paginated
  # endpoint.
  def match_paginated_api_response(expected)
    match_api_response(
      expected.merge(meta: a_serialized_pagination_metadata_hash)
    )
  end
  alias_method 'a_hash_matching_paginated_api_response',
    'match_paginated_api_response'

  # @return [AbsenceMatcher] a matcher indicating that a key shouldn't be
  #   present in an API response. Only useful in combination with
  #   ApiResponseMatcher.
  def absent
    AbsenceMatcher.new
  end
end


# Dir[Rails.root.join('spec/api_matchers/**/*.rb')].each { |f| require f }
