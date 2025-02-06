# frozen_string_literal: true

module Discover
  # Controller for API actions that search over the data sources included in the Discover bento
  class SearchController < ApplicationController
    # /discover/:source/results
    # render json from Results object
    def results
      source = params[:source]
      head(:bad_request) unless source.to_sym.in?(Discover::Configuration::SOURCES)

      results = results_for(source: source)
      render json: { data: results.entries, total_count: results.total_count, results_url: results.results_url }
    end

    private

    def search_params
      params.permit :q
    end

    def results_for(source:)
      source_klass.new(source: source).results(query: search_params[:q])
    end

    def source_klass
      source = params[:source].to_sym
      return Discover::Source::Blacklight if source.in?(Discover::Configuration::Blacklight::SOURCES)

      Discover::Source::PSE if source.in?(Discover::Configuration::PSE::SOURCES)
    end
  end
end
