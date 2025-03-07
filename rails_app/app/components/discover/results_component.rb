# frozen_string_literal: true

module Discover
  # Renders many Entry components
  class ResultsComponent < ResultsSkeletonComponent
    include Turbo::Streams::ActionHelper

    attr_reader :source, :count, :results

    # @param [Discover::Results] results
    # @param [Integer] count
    def initialize(results:, count: Configuration::RESULT_MAX_COUNT)
      @results = results
      @count = count
      @source = @results.source.source
    end

    # @return [String]
    def results_dom_id
      "#{id}-results-count"
    end

    # @return [String]
    def total_count_content
      total_count = number_with_delimiter(results&.total_count) || 0
      tag.span class: 'results-count', id: results_dom_id do
        "(#{total_count})"
      end
    end

    # @return [String]
    def results_button_content
      tag.a(id: results_button_id, class: 'btn btn-sm btn-primary', href: results.results_url) do
        t('discover.results.view_all_button.label', count: number_with_delimiter(results.total_count))
      end
    end
  end
end
