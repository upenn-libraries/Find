# frozen_string_literal: true

module Suggester
  # Factory class for SuggestionEngines
  class EngineRegistry
    BASE_CLASS = Suggester::SuggestionEngine
    class Error < StandardError
    end

    # @return [Array]
    def self.registry
      @registry ||= []
    end

    # @return [Array]
    def self.register(subclass)
      raise(Error, "#{subclass} must inherit from #{BASE_CLASS}") unless subclass < BASE_CLASS

      registry << subclass
    end

    # @return [Array<Suggester::SuggestionEngine>]
    def self.available_engines(query:, context:, engines: registry)
      engines.filter_map { |engine| engine.new(query: query, context: context) if engine.suggest?(query) }
    end
  end
end
