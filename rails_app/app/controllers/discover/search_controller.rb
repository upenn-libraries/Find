# frozen_string_literal: true

module Discover
  # Controller for API actions that search over the data sources included in the Discover bento
  class SearchController < ApplicationController
    SOURCES = [].freeze
    def results
      source = params[:source]
      head(:bad_request) && return unless source.in?(SOURCES)

      results = case source
                when :libraries then libraries_search_results(search_params)
                when :archives then archives_search_results(search_params)
                when :museums then museums_search_results(search_params)
                when :art_collections then art_collections_search_results(search_params)
                end
      render json: results
    end

    private

    def search_params
      params.permit(:q)
    end
  end
end
