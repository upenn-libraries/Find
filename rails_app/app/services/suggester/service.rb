# frozen_string_literal: true

# eagerly load classes in engine namespace to initialize engine registration
Dir[File.join(__dir__, 'engines', '*.rb')].each { |file| require file } if Suggester::Engines::Registry.engines.blank?

module Suggester
  # Builds JSON from suggestions provided by registered Engines
  class Service
    DEFAULT_ACTIONS_LIMIT = 2
    DEFAULT_COMPLETIONS_LIMIT = 4
    DEFAULT_CONTEXT = { actions_limit: DEFAULT_ACTIONS_LIMIT, completions_limit: DEFAULT_COMPLETIONS_LIMIT }.freeze

    # @param query [String]
    # @param context [Hash]
    # @param engine_classes [Array]
    def self.call(query:, context: {}, engine_classes: Engines::Registry.engines)
      new(query: query, context: context, engine_classes: engine_classes).response
    end

    attr_reader :query, :context, :engine_classes, :engines

    # @param query [String]
    # @param context [Hash]
    # @param engine_classes [Array]
    def initialize(query:, context: {}, engine_classes: Suggester::Engines::Registry.engines)
      @query = query
      @context = DEFAULT_CONTEXT.merge(context.symbolize_keys)
      @engine_classes = engine_classes
      @engines = Engines::Collection.new(query: query, context: @context, engine_classes: @engine_classes)
    end

    # @return [Hash]
    def response
      @response ||= { status: engines.status,
                      data: { params: { q: query, context: context.to_hash }, **engines.suggestions } }
    end
  end
end
