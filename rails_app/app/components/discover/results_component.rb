# frozen_string_literal: true

module Discover
  # Renders many Entry components
  class ResultsComponent < ViewComponent::Base
    attr_reader :source, :count, :results

    # @param [Discover::Results] results
    # @param [Integer] count
    def initialize(results:, count: 3)
      @results = results
      @count = count
      @source = @results.source.source
    end

    def results?
      results.entries.present?
    end
  end
end
