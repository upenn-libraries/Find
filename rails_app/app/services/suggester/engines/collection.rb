# frozen_string_literal: true

module Suggester
  module Engines
    # Provides interface for requesting suggestions from a collection of SuggestionEngines
    class Collection
      attr_reader :query, :context, :engine_classes, :registry

      # @param query [String]
      # @param context [Hash]
      # @param engine_classes [Array]
      # @param registry [Class<Suggester::EngineRegistry>]
      def initialize(query:, context: {}, engine_classes: Suggester::Engines::Registry.engines, registry: Suggester::Engines::Registry)
        @query = query
        @context = context
        @engine_classes = engine_classes
        @registry = registry
      end

      # @return [Hash{Symbol->SuggestionCollection}]
      def suggestions
        @suggestions ||= {
          suggestions: {
            actions: Suggester::Suggestions::Collection.new(suggestions: engines.flat_map(&:actions))
                                                       .provide(limit: context[:actions_limit].to_i),
            completions: Suggester::Suggestions::Collection.new(suggestions: engines.flat_map(&:completions))
                                                           .provide(limit: context[:completions_limit].to_i)
          }
        }
      end

      # @return [Symbol]
      def status
        engines.any? ? :success : :failure
      end

      # @return [Array<Suggester::SuggestionEngine>]
      def engines
        @engines ||= build_engines.select(&:success?)
      end

      private

      # @return [Array<Suggester::SuggestionEngine>]
      def build_engines
        registry.build_eligible_engines(query: query, context: context, engines: engine_classes)
      end
    end
  end
end
