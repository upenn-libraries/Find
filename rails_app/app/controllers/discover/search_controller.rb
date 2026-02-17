# frozen_string_literal: true

module Discover
  # Controller for API actions that search over the data sources included in the Discover bento
  class SearchController < ApplicationController
    # /discover/:source/results
    # render json from Results object
    def results
      source = params[:source]
      count = params[:count]&.to_i
      return head(:bad_request) unless source.to_sym.in?(Discover::Configuration::SOURCES)

      results = results_for(source: source)

      respond_to do |format|
        format.html do
          render Discover::ResultsComponent.new(results: results, source: source, count: count), layout: false
        end
      end
    end

    private

    def search_params
      params.permit :q
    end

    # @param [String] source
    # @return [Discover::Results]
    def results_for(source:)
      source_klass(source: source).results(query: search_params[:q])
    end

    # @return [Discover::Source]
    def source_klass(source:)
      Discover::Source.create_source(source: source)
    end
  end
end
