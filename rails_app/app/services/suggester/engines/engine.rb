# frozen_string_literal: true

module Suggester
  module Engines
    # Class that Engines inherit from
    class Engine
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
        @suggestion_class = Suggester::Suggestions::Suggestion
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
