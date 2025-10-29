# frozen_string_literal: true

module Suggester
  # Base class that registers SuggestionEngines and implements abstract api
  class SuggestionEngine
    # @return [Integer]
    def self.weight
      0
    end

    # @param query [String]
    # @return [Boolean]
    def self.suggest?(query)
      query.present?
    end

    attr_reader :query, :context

    # @param query [String]
    # @param context [Hash]
    def initialize(query:, context: {})
      @query = query
      @context = context
    end

    # @return [Suggestions]
    def actions
      Suggestion.new
    end

    # @return [Suggestions]
    def completions
      Suggestion.new
    end

    # @return [Boolean]
    def success?
      actions.present? || completions.present?
    end
  end
end
