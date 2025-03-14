# frozen_string_literal: true

module Discover
  # Render main page content for the collection bento
  class MainPageComponent < ViewComponent::Base
    # @param params [ActionController::Parameters]
    def initialize(params:)
      @params = params
    end

    def call
      component = if discover_query.present?
                    Discover::SearchResultsComponent.new(query: discover_query, count: count,
                                                         render_pse_sources: render_pse_sources?)
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

    # @return [String]
    def discover_query
      params[:q].to_s
    end

    # @return [Integer]
    def count
      params[:count].present? ? params[:count].to_i : Configuration::RESULT_MAX_COUNT
    end
  end
end
