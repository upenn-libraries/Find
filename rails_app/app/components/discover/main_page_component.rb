# frozen_string_literal: true

module Discover
  # Render main page content the collection bento
  class MainPageComponent < ViewComponent::Base
    def initialize(params:)
      @params = params
    end

    def call
      component = if discover_query.present?
                    Discover::SearchResultsComponent.new(query: discover_query, render_pse_sources: render_pse_sources?)
                  else
                    Discover::HomepageComponent.new
                  end
      render component
    end

    private

    # @return [Boolean]
    def render_pse_sources?
      params[:no_pse] != 'true'
    end

    def discover_query
      params[:q]
    end
  end
end
