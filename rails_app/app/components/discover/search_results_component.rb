# frozen_string_literal: true

module Discover
  # Render the search results
  class SearchResultsComponent < ViewComponent::Base
    attr_reader :query, :render_pse_sources

    def initialize(query:, render_pse_sources: true)
      @query = query
      @render_pse_sources = render_pse_sources
    end
  end
end
