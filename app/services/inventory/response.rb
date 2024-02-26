# frozen_string_literal: true

module Inventory
  # Response object for Inventory Service calls
  class Response
    attr_reader :entries, :total_count, :limit, :document

    def initialize(entries:, total_count:, limit:, document:)
      @entries = entries
      @total_count = total_count
      @limit = limit
      @document = document
    end
  end
end
