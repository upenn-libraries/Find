# frozen_string_literal: true

module Discover
  # Render the search results
  class SearchResultsComponent < ViewComponent::Base
    attr_reader :query, :count, :render_pse_sources

    # @param query [String] search query to use when loading source panels
    # @param render_pse_sources [Boolean] whether or not to disable Google PSE-based sources
    def initialize(query:, count:, render_pse_sources: true)
      @query = query
      @count = count
      @render_pse_sources = render_pse_sources
    end
  end
end
