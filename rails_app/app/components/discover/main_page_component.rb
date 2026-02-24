# frozen_string_literal: true

module Discover
  # Render main page content for the collection bento
  class MainPageComponent < ViewComponent::Base
    attr_reader :query, :count

    # @param query [String]
    # @param count [Integer]
    def initialize(query:, count: nil)
      @query = query
      @count = count&.to_i&.clamp(1, 10) || Configuration::RESULT_MAX_COUNT
    end

    def call
      component = if query.present?
                    Discover::SearchResultsComponent.new(query: query, count: count)
                  else
                    Discover::HomepageComponent.new
                  end
      render component
    end
  end
end
