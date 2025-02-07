# frozen_string_literal: true

module Discover
  # Controller for API actions that search over the data sources included in the Discover bento
  class SearchController < ApplicationController
    # /discover/:source/results
    # render json from Results object
    def results
      source = params[:source]
      return head(:bad_request) unless source.to_sym.in?(Discover::Configuration::SOURCES)

      results = results_for(source: source)
      render json: { data: results.entries, total_count: results.total_count,
                     results_url: results.results_url, source: results.source }
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
