module RSpecJsonMatchers
  # This is a special matcher that always returns false under normal
  # circumstances, used to indicate keys that should not be present in a given
  # API response.
  #
  # The only circumstance where the matcher may return true is in the class
  # method `is_an_absence_matcher?`, which takes a matcher and feeds a special
  # `ABSENCE_MARKER` value into it which should fail every possible matcher
  # other than AbsenceMatcher, which it passes. We can use this to determine
  # whether it's OK for a given key to be absent from a response. TODO: try to
  # make this explanation less confusing.
  class AbsenceMatcher < RSpec::Matchers::BuiltIn::Equal
    ABSENCE_MARKER = Object.new

    # Test whether the given matcher is either an instance of AbsenceMatcher or
    # a compound matcher containing an AbsenceMatcher, like
    # 'absent.or(a_kind_of(Integer))'.
    def self.is_an_absence_matcher?(matcher)
      matcher === ABSENCE_MARKER && !(matcher === Object.new)
    end

    def initialize
      @expected = ABSENCE_MARKER
    end

    def description
      'absent'
    end
  end
end
