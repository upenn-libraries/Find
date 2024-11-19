# frozen_string_literal: true

module Inventory
  class List
    # Response object for Inventory Service calls
    class Response
      include Enumerable

      attr_reader :entries

      # @param [Array] entries
      def initialize(entries:, complete: true)
        @entries = entries
        @complete = complete
      end

      def each(&)
        entries.each(&)
      end

      # This conveys that we take this response to be the complete record of what we have - aka no error occurred when
      # retrieving the inventory.
      # @return [Boolean]
      def complete?
        @complete
      end
    end
  end
end
