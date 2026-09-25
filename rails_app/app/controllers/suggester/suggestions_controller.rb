# frozen_string_literal: true

module Suggester
  # Controller actions for serving search suggestions
  class SuggestionsController < ApplicationController
    class SuggesterFailed < StandardError; end

    # The listbox a search box replaces when it has no say in the matter
    DEFAULT_LISTBOX_ID = 'suggestions-listbox'

    # Before validate_query, so an error response knows where to render too
    before_action :set_listbox_id
    before_action :validate_query

    rescue_from StandardError, with: :error_response

    # /suggester/:q?actions_limit=2&completions_limit=4
    def show
      suggestions = Suggester::Service.call(query: params[:q].to_s, context: context_params)

      raise SuggesterFailed unless suggestions[:status] == :success

      respond_to do |format|
        format.turbo_stream do
          @completions = suggestions.dig(:data, :suggestions, :completions)
          @actions = suggestions.dig(:data, :suggestions, :actions)
        end
      end
    end

    private

    # A page can hold more than one search box, so the box that asked names the listbox to replace.
    # Constrained to the shape of an html id, since it is echoed back into the response.
    # @return [String]
    def set_listbox_id
      id = params[:listbox].to_s

      @listbox_id = id.match?(/\A[A-Za-z][\w-]*\z/) ? id : DEFAULT_LISTBOX_ID
    end

    def validate_query
      return if params[:q].present?

      raise SuggesterFailed, 'The given query parameters are invalid.'
    end

    # Empty the listbox if the suggester response is an error
    def error_response
      respond_to do |format|
        format.turbo_stream do
          render 'suggester/suggestions/error', layout: false, status: :internal_server_error
        end
      end
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
