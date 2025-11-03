# frozen_string_literal: true

module Suggester
  # Controller actions for serving search suggestions
  class SuggestionsController < ApplicationController
    class InvalidQueryError < StandardError; end

    before_action :validate_query

    rescue_from InvalidQueryError, with: :error_response

    # /suggester/:q?actions_limit=2&completions_limit=4
    def show
      suggestions = Suggester::Service.call(query: params[:q].to_s, context: context_params)

      # TODO: handle failed suggestions response

      respond_to do |format|
        format.turbo_stream do
          @completions = suggestions.dig(:data, :suggestions, :completions)
          @actions = suggestions.dig(:data, :suggestions, :actions)
        end
      end
    end

    private

    def validate_query
      return if params[:q].present?

      raise InvalidQueryError, 'The given query parameters are invalid.'
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
