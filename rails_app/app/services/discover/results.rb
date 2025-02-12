# frozen_string_literal: true

module Discover
  # Object intended to provide the source results to a view component
  class Results
    include Enumerable

    attr_reader :source, :total_count, :results_url

    # @param entries [Array<Hash>]
    # @param [Discover::Source] source
    # @param [Integer] total_count
    # @param [String] results_url
    def initialize(entries:, source:, total_count:, results_url:)
      @entries = entries
      @source = source
      @total_count = total_count
      @results_url = results_url
    end

    def each(&)
      @entries.each(&)
    end
  end
end
