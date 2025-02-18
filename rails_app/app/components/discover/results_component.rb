# frozen_string_literal: true

module Discover
  # Renders many Entry components
  class ResultsComponent < ViewComponent::Base
    include Turbo::Streams::ActionHelper

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

    # @return [String]
    def results_dom_id
      "#{source}-results-count"
    end

    # @return [String]
    def total_count_content
      total_count = number_with_delimiter(results&.total_count) || 0
      tag.span class: 'results-count', id: results_dom_id do
        "(#{total_count})"
      end
    end
  end
end
