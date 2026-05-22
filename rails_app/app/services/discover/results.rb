# frozen_string_literal: true

module Discover
  # Object intended to provide the source results to a view component
  class Results
    include Enumerable

    attr_reader :source, :total_count, :results_url

    # @param records [Array<Discover::Record>]
    # @param source [Discover::Source]
    # @param total_count [Integer]
    # @param results_url [String]
    def initialize(records:, source:, total_count:, results_url:)
      @records = records
      @source = source
      @total_count = total_count
      @results_url = results_url
    end

    def each(&)
      @records.each(&)
    end
  end
end
