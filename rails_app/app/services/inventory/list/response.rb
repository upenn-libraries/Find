# frozen_string_literal: true

module Inventory
  class List
    # Response object for Inventory Service calls
    class Response
      include Enumerable

      attr_reader :entries

      # @param [Array] entries
      def initialize(entries:)
        @entries = entries
      end

      def each(&)
        entries.each(&)
      end
    end
  end
end
