# frozen_string_literal: true

module Suggester
  # Controller actions for serving search suggestions
  class SuggestionsController < ApplicationController
    class InvalidQueryError < StandardError; end

    before_action :validate_query

    rescue_from InvalidQueryError, with: :error_response

    # /suggester/:q?count=5
    def show
      render json: Suggester::Service.call(query: params[:q].to_s, context: context_params)
    end

    private

    def validate_query
      return if params[:q].present?

      raise InvalidQueryError, 'The given query parameters are invalid.'
    end

    # @param [ActionController::Parameters] params
    # @return [Hash]
    def dummy_response(params)
      {
        status: 'success', # if failure, the consuming app can act accordingly
        data: {
          params: {
            q: params[:q], context: context_params
          }, # echo back received params
          suggestions: {
            actions: [ # actions are search actions and will redirect the user when selected
              { label: 'Search titles for "query"', url: 'https://find.library.upenn.edu/?field=title&q=query' }
            ],
            completions: [ # completions are suggestions that can be selected and will fill the search bar
              'query syntax', 'query language', 'query errors', 'adversarial queries'
            ]
          } # end suggestions
        } # end data
      }
    end

    # @param [StandardError] exception
    def error_response(exception)
      render json: { status: :error, message: exception.message }, status: :bad_request
    end

    # @return filtered context params [ActiveSupport::HashWithIndifferentAccess]
    def context_params
      params.permit.merge(normalize_limit_params).to_h
    end

    # @return filtered context params [ActiveSupport::HashWithIndifferentAccess]
    def normalize_limit_params
      params.permit('actions_limit', 'completions_limit').transform_values(&:to_i)
    end
  end
end
