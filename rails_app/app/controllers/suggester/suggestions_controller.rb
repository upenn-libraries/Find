# frozen_string_literal: true

module Suggester
  # Controller actions for serving search suggestions
  class SuggestionsController < ApplicationController
    class InvalidQueryError < StandardError; end

    before_action :validate_query

    rescue_from InvalidQueryError, with: :error_response

    # /suggester/:q?count=5
    def show
      suggestions = dummy_suggestions(params)
      
      respond_to do |format|
        format.turbo_stream do
          @completions = suggestions[:completions]
          @actions = suggestions[:actions]
        end
      end
    end

    private

    def validate_query
      return if params[:q].present?

      raise InvalidQueryError, 'The given query parameters are invalid.'
    end

    # @param [ActionController::Parameters] params
    # @return [Hash]
    def dummy_suggestions(params)
      {
        actions: [ # actions are search actions and will redirect the user when selected
          { label: 'Search titles for "query"', url: 'https://find.library.upenn.edu/?field=title&q=query' }
        ],
        completions: [ # completions are suggestions that can be selected and will fill the search bar
          'query syntax', 'query language', 'query errors', 'adversarial queries'
        ]
      }
    end

    # @param [ActionController::Parameters] params
    # @return [Hash]
    def dummy_response(params)
      {
        status: 'success', # if failure, the consuming app can act accordingly
        data: {
          params: {
            q: params[:q], context: context_params(params).to_h
          }, # echo back received params
          suggestions: dummy_suggestions(params)
        } # end data
      }
    end

    # @param [StandardError] exception
    def error_response(exception)
      render json: { status: :error, message: exception.message }, status: :bad_request
    end

    # @param params [ActionController::Params]
    # @return [ActionController::Params] filtered context params
    def context_params(params)
      params.permit(:count)
    end
  end
end
