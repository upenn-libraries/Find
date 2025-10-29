# frozen_string_literal: true

module Suggester
  # Builds JSON from suggestions provided by registered Suggestions
  class SuggestionsService
    DEFAULT_ACTIONS_LIMIT = 2
    DEFAULT_COMPLETIONS_LIMIT = 4
    DEFAULT_CONTEXT = { actions_limit: DEFAULT_ACTIONS_LIMIT, completions_limit: DEFAULT_COMPLETIONS_LIMIT }.freeze

    # @param query [String]
    # @param context [Hash]
    # @param engine_classes [Array]
    def self.call(query:, context: {}, engine_classes: EngineRegistry.registry)
      new(query: query, context: context, engine_classes: engine_classes).response
    end

    attr_reader :query, :context, :engine_classes, :engines

    # @param query [String]
    # @param context [Hash]
    # @param engine_classes [Array]
    def initialize(query:, context: {}, engine_classes: EngineRegistry.registry)
      @query = query
      @context = DEFAULT_CONTEXT.merge(context.symbolize_keys)
      @engine_classes = engine_classes
      @engines = EngineCollection.new(query: query, context: @context, engine_classes: @engine_classes)
    end

    # @return [Hash]
    def response
      @response ||= { status: engines.status,
                      data: { params: { q: query, context: context.to_hash }, **engines.suggestions } }
    end
  end
end
