# frozen_string_literal: true

module Discover
  # Controller for API actions that search over the data sources included in the Discover bento
  class SearchController < ApplicationController
    def results
      source = params[:source]
      head(:bad_request) && return unless source.to_sym.in?(Discover::Configuration::SOURCES) # TODO: legit syntax

      results = results_for source: source
      render json: results
    end

    private

    def search_params
      params.permit(:q)
    end

    # Dynamically instantiate the proper Source object and get the results from that source
    # @param source [Symbol]
    # @return [Discover::Results]
    def results_for(source:)
      source = Discover::Source.type(source: source)&.new(params: search_params)
      raise unless source

      source.results
    end
  end
end
