# frozen_string_literal: true

module Suggester
  # Controller actions for serving search suggestions
  class SuggestionsController < ApplicationController
    # /suggestions/:q?count=5
    def show
      render json: dummy_response(params)
    end

    private

    # @param [ActionController::Parameters] params
    # @return [Hash]
    def dummy_response(params)
      {
        status: 'success', # if failure, the consuming app can act accordingly
        data: {
          params: {
            q: params[:q], context: context_params(params).to_h
          }, # echo back received params
          suggestions: {
            actions: [ # actions are search actions and will redirect the user when selected
              { label: 'Search titles for "query"', url: 'http://find.edu/?field=title&q=query' }
            ],
            completions: [ # completions are suggestions that can be selected and will fill the search bar
              'query syntax', 'query language', 'query errors', 'adversarial queries'
            ]
          } # end suggestions
        } # end data
      }
    end

    # @param params [ActionController::Params]
    # @return [ActionController::Params] filtered context params
    def context_params(params)
      params.permit(:count)
    end
  end
end
