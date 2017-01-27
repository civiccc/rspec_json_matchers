module RSpecJsonMatchers
  # Helper class that powers our DSL for defining API matchers.
  class JsonMatcherDefinition < BasicObject
    def initialize
      @attrs = {}
    end

    # Defines a matcher for the specified field.
    # @param method_name [Symbol] Name of the field to match against
    # @block Block which, when called, returns matcher used to verify actual
    #   data
    # @example
    #   id { a_kind_of Integer } # the id attribute should be a number
    # rubocop:disable Style/MethodMissing
    # disabled since method existence can depend on args / block
    def method_missing(name, *args, &block)
      if args.length > 0 || block.nil?
        super
      else
        @attrs[name.to_s] = block
      end
    end
    # rubocop:enable Style/MethodMissing

    # @param matcher_context [Object] The context in which to run the matcher
    #   procs. This should be the spec instance.
    # @return [Hash] of field name, matcher pairs to be used for validation
    def to_hash(matcher_context)
      ::Hash[@attrs.map do |name, matcher_proc|
        [name, matcher_context.instance_exec(&matcher_proc)]
      end]
    end
  end
end
