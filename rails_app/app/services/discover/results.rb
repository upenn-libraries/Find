# frozen_string_literal: true

module Discover
  # Object intended to provide the source results to a view component
  class Results
    include Enumerable

    # @param entries [Array<Hash>]
    # @param [Discover::Source] source
    def initialize(entries:, source:)
      @source = source
      @entries = entries
    end

    def each(&)
      @entries.each(&)
    end
  end
end
