# frozen_string_literal: true

module Discover
  # Placeholder component that renders initial page load and fetches results turbo-frame
  class ResultsSkeletonComponent < ViewComponent::Base
    attr_reader :query, :disabled, :results, :count, :presenter

    delegate(*Discover::Results::ResultsPresenter::VALUES, to: :presenter)

    # @param source [String, Symbol]
    # @param query [String]
    # @param results [Array]
    # @param disabled [Boolean]
    def initialize(source:, query: '', results: [], disabled: false, count: Configuration::RESULT_MAX_COUNT)
      @query = query
      @results = results
      @disabled = disabled
      @count = count
      @presenter = Discover::Results::ResultsPresenter.new(source: source)
    end
  end
end
