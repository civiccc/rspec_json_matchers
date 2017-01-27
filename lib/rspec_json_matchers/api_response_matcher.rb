module RSpecJsonMatchers
  # General matcher for API responses, used to compose matchers for the overall
  # API response or individual model serializations.
  class ApiResponseMatcher < RSpec::Matchers::BuiltIn::BaseMatcher
    attr_reader :results_with_errors

    def initialize(expected,
                   object_definition: nil,
                   object_name: nil,
                   context: nil)
      @expected = expected
      @object_definition = object_definition
      @object_name = object_name
      @context = context
    end

    # Use our implementation of FuzzyMatcher to test the given data against our
    # expected data.
    # @param expected [Object] Expected values or matchers
    # @param actual [Object] Actual data to be validated
    # @return [Boolean]
    def matches?(actual)
      @actual = actual

      if @object_definition
        combined = @expected.reverse_merge @object_definition.to_hash(@context)
      end

      @did_match, @results_with_errors =
        FuzzyMatcher.match_values(combined || @expected, @actual)
      @did_match
    end

    # Overrides `failure_message` to return our own field specific failure
    # messsages with color!
    # @return [String]
    def failure_message
      "Expected API response to match specification:\n#{pretty_results}"
    end

    # Overrides `failure_message_when_negated` when testing that an API response
    # does not include a resource.
    # @return [String]
    def failure_message_when_negated
      "Expected API response not to match specification, but it did:\n#{pretty_results}"
    end

    # Formats our results object with PP and, resetting the color at the
    # beginning of each line to override RSpec's default coloring.
    # @return [String]
    def pretty_results
      @results_with_errors.pretty_inspect.gsub(/^/, "\e[0m")
    end

    # If we have explicitly defined the type of API matcher we want, report
    # that, otherwise describe the general API matcher
    # @return [String]
    def description
      description = surface_descriptions_in(@expected).inspect

      if @object_name
        "a serialized #{@object_name}" \
          "#{" matching #{description}" if description != '{}'}"
      else
        "an api response matching #{description}"
      end
    end

    # Overridden because we don't want to inspect `@object_definition` and
    # `@context`
    # @return [String]
    def inspect
      "#<ApiResponseMatcher#{" for #{@object_name}" if @object_name}>"
    end
  end
end
