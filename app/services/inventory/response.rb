# frozen_string_literal: true

module Inventory
  # Response object for Inventory Service calls
  class Response
    attr_reader :entries, :remainder

    # @param [Array] entries
    # @param [Integer] remainder number of entries that are not included in the entries array
    def initialize(entries:, remainder:)
      @entries = entries
      @remainder = remainder
    end

    def each(&)
      entries.each(&)
    end
  end
end
