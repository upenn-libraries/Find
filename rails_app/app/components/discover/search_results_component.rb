# frozen_string_literal: true

module Discover
  # Render the search results
  class SearchResultsComponent < ViewComponent::Base
    attr_reader :query, :count

    # @param query [String] search query to use when loading source panels
    # @param count [Integer] maximum number of results to render
    def initialize(query:, count:)
      @query = query
      @count = count
    end
  end
end
