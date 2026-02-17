# frozen_string_literal: true

module Discover
  # Render main page content for the collection bento
  class MainPageComponent < ViewComponent::Base
    attr_reader :query, :count, :render_pse

    # @param query [String]
    # @param count [Integer]
    # @param render_pse [Boolean] whether to render any PSE sources
    def initialize(query:, count: nil, render_pse: true)
      @query = query
      @count = count&.to_i&.clamp(1, 10) || Configuration::RESULT_MAX_COUNT
      @render_pse = render_pse
    end

    def call
      component = if query.present?
                    Discover::SearchResultsComponent.new(query: query, count: count, render_pse: render_pse)
                  else
                    Discover::HomepageComponent.new
                  end
      render component
    end
  end
end
