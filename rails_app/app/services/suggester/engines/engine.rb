# frozen_string_literal: true

module Suggester
  module Engines
    # Class that Engines inherit from
    class Engine
      BASE_ACTIONS_WEIGHT = 0
      BASE_COMPLETIONS_WEIGHT = 0

      # @return [Integer]
      def self.actions_weight
        self::BASE_ACTIONS_WEIGHT
      end

      # @return [Integer]
      def self.completions_weight
        self::BASE_COMPLETIONS_WEIGHT
      end

      # @param query [String]
      # @return [Boolean]
      def self.suggest?(query)
        query.present?
      end

      # Simple class for recommended action
      Action = Data.define(:label, :url)

      attr_reader :query, :context

      # @param query [String]
      # @param context [Hash]
      def initialize(query:, context: {})
        @query = query
        @context = context
      end

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new
      end

      # @return [Suggester::Suggestions::Suggestion]
      def completions
        Suggestions::Suggestion.new
      end

      # @return [Boolean]
      def success?
        actions.present? || completions.present?
      end
    end
  end
end
