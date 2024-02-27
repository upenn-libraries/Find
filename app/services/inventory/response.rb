# frozen_string_literal: true

module Inventory
  # Response object for Inventory Service calls
  class Response
    attr_accessor :entries, :total_count
    attr_reader :limit

    def initialize(entries:, total_count: nil, limit: nil)
      @entries = entries
      @total_count = total_count
      @limit = limit
    end

    def each(&)
      entries.each(&)
    end
  end
end
