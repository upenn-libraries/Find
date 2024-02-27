# frozen_string_literal: true

module Inventory
  # Response object for Inventory Service calls
  class Response
    attr_accessor :entries, :total_count, :limit

    # @param [Array] entries
    # @param [Integer] remainder
    def initialize(entries:, remainder:)
      @entries = entries
      @remainder = remainder
    end

    def each(&)
      entries.each(&)
    end
  end
end
