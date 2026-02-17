# frozen_string_literal: true

module Discover
  # Renders many Entry components
  class ResultsComponent < ResultsSkeletonComponent
    include Turbo::Streams::ActionHelper

    attr_reader :count, :results, :presenter

    delegate(*Discover::Results::ResultsPresenter::VALUES, to: :presenter)

    # @param results [Discover::Results]
    # @param source [Symbol]
    # @param count [Integer]
    def initialize(results:, source:, count:)
      @results = results
      @count = count.to_i
      @presenter = Discover::Results::ResultsPresenter.new(source: source)
    end

    # @return [Boolean]
    def results?
      results.any?
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
