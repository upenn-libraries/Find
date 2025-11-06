# frozen_string_literal: true

module Suggester
  module Engines
    # Factory class for SuggestionEngines
    class Registry
      BASE_CLASS = Engine
      # Custom error
      class Error < StandardError
      end

      # @return [Array<Suggester::Engines::Engine>]
      def self.engines
        load_engines if @engines.blank?
        @engines ||= []
      end

      # Eagerly load all engines into memory to initialize engine registration
      def self.load_engines
        Dir[File.join(__dir__, '*.rb')].each { |file| require file }
      end

      # @return [Array<Suggester::Engines::Engine>]
      def self.register(subclass)
        raise(Error, "#{subclass} must inherit from #{BASE_CLASS}") unless subclass < BASE_CLASS

        engines << subclass unless engines.include?(subclass)
      end

      # clear registered engines
      def self.clear!
        @engines = nil
      end

      # @return [Array<Suggester::Engines::Engine>]
      def self.build_eligible_engines(query:, context:, engines: self.engines)
        engines.filter_map { |engine| engine.new(query: query, context: context) if engine.suggest?(query) }
      end
    end
  end
end
