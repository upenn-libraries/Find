# frozen_string_literal: true

module Discover
  # Renders the overview area listing each source and the count of results
  class ResultsOverviewComponent < ViewComponent::Base
    attr_reader :query

    def initialize(query:)
      @query = query
    end
  end
end
