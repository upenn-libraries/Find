# frozen_string_literal: true

module Discover
  # Render the search results
  class SearchResultsComponent < ViewComponent::Base
    attr_reader :query, :count, :render_pse

    # @param query [String] search query to use when loading source panels
    # @param count [Integer] maximum number of results to render
    # @param render_pse [Boolean] whether to disable Google PSE-based sources
    def initialize(query:, count:, render_pse:)
      @query = query
      @count = count
      @render_pse = render_pse
    end
  end
end
