# frozen_string_literal: true

module Discover
  # Renders many Entry components
  class ResultsComponent < ViewComponent::Base
    attr_reader :source, :count, :results

    # @param [Discover::Results] results
    # @param [Integer] count
    def initialize(results:, count: Configuration::RESULT_MAX_COUNT)
      @results = results
      @count = count
      @source = @results.source.source
    end

    def results?
      results.any?
    end
  end
end
