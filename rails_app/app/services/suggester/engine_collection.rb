# frozen_string_literal: true

module Suggester
  # Provides interface for requesting suggestions from a collection of SuggestionEngines
  class EngineCollection
    attr_reader :query, :context, :engine_classes, :registry

    # @param query [String]
    # @param context [Hash]
    # @param engine_classes [Array]
    # @param registry [Class<Suggester::EngineRegistry>]
    def initialize(query:, context: {}, engine_classes: EngineRegistry.registry, registry: EngineRegistry)
      @query = query
      @context = context
      @engine_classes = engine_classes
      @registry = registry
    end

    # @return [Hash{Symbol->SuggestionCollection}]
    def suggestions
      @suggestions ||= {
        suggestions: {
          actions: SuggestionCollection.new(suggestions: engines.flat_map(&:actions))
                                       .provide(limit: context[:actions_limit].to_i),
          completions: SuggestionCollection.new(suggestions: engines.flat_map(&:completions))
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
      registry.available_engines(query: query, context: context, engines: engine_classes)
    end
  end
end
