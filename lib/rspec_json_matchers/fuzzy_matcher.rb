module RSpecJsonMatchers
  # This is a fork of `RSpec::Support::FuzzyMatcher`, which is a tool used to
  # recursively match a given structure (of arrays, hashes, and other objects)
  # against an expected structure. The expected structure can contain scalar
  # values or RSpec matchers; leaves are compared using the `===` operator.
  #
  # The differences between this module and the RSpec version are:
  # * Instead of implementing predicate methods that return true or false (and
  #   bail out of the recursion as soon as they notice a problem), our methods
  #   return both a success value and a representation of the structure that
  #   includes failure messages. That lets us show exactly where the structures
  #   differed in a way that's more reliable than textual diffing.
  # * We support `absent` (`RSpecJsonMatchers::AbsenceMatcher`) as a placeholder
  #   that means "this key should not exist in the hash we're matching
  #   against".
  module FuzzyMatcher
    extend RSpec::Matchers::Composable # for surface_descriptions_in

    # Simple wrapper for formatting individual errors in a failure message.
    class FailureDescription
      # @param message [String] Message to be rendered.
      def initialize(message)
        @message = message
      end

      # @return [String] the given message, with extra formatting and red
      #   highlighting.
      def inspect
        "\e[31m(FAILURE: #{@message})\e[0m"
      end
    end

    # Helper used to match individual values against each other. If the values
    # are arrays or hashes, we delegate to match_arrays or match_hashes.
    # @param expected [Object] expected values or matchers
    # @param actual [Object] actual data
    # @return [Array(Boolean, Object)] a tuple whose first member is a Boolean
    #   representing whether the match succeeded and whose second member is
    #   something which, when `pretty_inspect` is called on it, will return a
    #   string representing the original value where the match succeeded or
    #   describing the failure where the match failed.
    def self.match_values(expected, actual)
      if Array === expected && Enumerable === actual
        return match_arrays(expected, actual.to_a)
      end

      if Hash === expected && Hash === actual
        return match_hashes(expected, actual)
      end

      begin
        did_match = (actual == expected || expected === actual)
      rescue ArgumentError
        # Some objects, like 0-arg lambdas on 1.9+, raise
        # ArgumentError for `expected === actual`.
        false
      end

      if did_match
        [true, actual]
      else
        [false, extract_results_with_errors(expected, actual)]
      end
    end

    # Helper used to match arrays against each other.
    # @param expected_list [Array] expected values or matchers
    # @param actual_list [Array] actual data
    # @return [Array(Boolean, Array)] a tuple whose first member is a
    #   Boolean representing whether the match succeeded and whose second
    #   member is something which, when `pretty_inspect` is called on it, will
    #   return a string representing the original value where the match
    #   succeeded or describing the failure where the match failed.
    def self.match_arrays(expected_list, actual_list)
      all_matched = true
      result_list = []

      # For indexes that are present in both lists, match the values against
      # their respective expectations.
      expected_list.take(actual_list.length).each_with_index do |expected, idx|
        actual = actual_list[idx]
        value_matched, value = match_values(expected, actual)
        all_matched &&= value_matched
        result_list << value
      end

      # If the expected list was longer, add "was absent" errors.
      expected_list.drop(actual_list.length).each do |expected|
        all_matched = false
        result_list << failed_match_message(expected, 'absent')
      end

      # If the actual list was longer, add "should have been absent" errors.
      actual_list.drop(expected_list.length).each do |actual|
        all_matched = false
        result_list << extra_key_message(actual.inspect)
      end

      [all_matched, result_list]
    end

    # Helper used to match hashes against each other. Also checks for the
    # existence of unexpected keys and the absence of expected keys.
    # @param expected_hash [Hash] expected values or matchers
    # @param actual_hash [Hash] actual data
    # @return [Array(Boolean, Hash)] a tuple whose first member is a Boolean
    #   representing whether the match succeeded and whose second member is
    #   something which, when `pretty_inspect` is called on it, will return a
    #   string representing the original value where the match succeeded or
    #   describing the failure where the match failed.
    def self.match_hashes(expected_hash, actual_hash)
      all_matched = true
      result_hash = {}

      # Stringify expected keys so that we can use new-style hashes in our
      # specs.
      expected_hash = expected_hash.stringify_keys

      # Errors for missing keys, or extra keys are created at the hash level
      # because it is difficult to detect at the element level whether or not a
      # `nil` value is caused by a missing key, or an actual `nil` value.
      expected_hash.each do |expected_key, expected_value|
        if actual_hash.key?(expected_key)
          actual_value = actual_hash[expected_key]
          value_matched, value = match_values(expected_value, actual_value)
          all_matched &&= value_matched
        elsif AbsenceMatcher.is_an_absence_matcher?(expected_value)
          # We expected the value to not be present, and it isn't, so we're all
          # good.
        else
          # Mark any missing keys as failures
          value = failed_match_message(expected_value, 'absent')
          all_matched = false
        end

        result_hash[expected_key] = value
      end

      # If there are extra keys, we should mark them as invalid
      (actual_hash.keys - expected_hash.keys).each do |key|
        result_hash[key] = extra_key_message(actual_hash[key].inspect)
        all_matched = false
      end

      [all_matched, result_hash]
    end

    def self.extract_results_with_errors(expected, actual)
      if expected.respond_to?(:results_with_errors)
        return expected.results_with_errors
      end

      case expected
      when RSpec::Matchers::BuiltIn::Compound::Or
        extract_results_from_or_matcher(expected, actual)
      when RSpec::Matchers::BuiltIn::All
        extract_results_from_all_matcher(expected, actual)
      else
        failed_match_message(expected, actual.inspect)
      end
    end

    # Check both branches for structured results before falling back to the
    # matcher's description method.
    def self.extract_results_from_or_matcher(expected, actual)
      [expected.matcher_1, expected.matcher_2].each do |matcher|
        result = extract_results_with_errors(matcher, actual)
        return result unless result.is_a?(FailureDescription)
      end

      failed_match_message(expected, actual.inspect)
    end

    # To deal with the `all` matcher, we need to rerun the matcher on each
    # element so that we can then try to extract results from it.
    def self.extract_results_from_all_matcher(expected, actual)
      unless actual.respond_to?(:map)
        return failed_match_message(expected, actual.inspect)
      end

      actual.map do |actual_item|
        cloned_matcher = expected.matcher.clone
        matches = cloned_matcher.matches?(actual_item)

        if matches
          actual_item
        else
          extract_results_with_errors(cloned_matcher, actual_item)
        end
      end
    end

    # Generate a failure description based on expected and actual values.
    # @param expected [Object] expected matcher or value
    # @param actual [Object] actual value
    # @return [FailureDescription]
    def self.failed_match_message(expected, actual)
      description = surface_descriptions_in(expected).inspect
      FailureDescription.new("was #{actual}, should have been #{description}")
    end

    # Generate a failure description for a key that should not have been
    # present.
    # @param actual_value [Object]
    # @return [FailureDescription]
    def self.extra_key_message(actual_value)
      FailureDescription.new("was #{actual_value}, should have been absent")
    end
  end
end
