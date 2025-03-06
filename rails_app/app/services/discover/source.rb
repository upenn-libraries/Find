# frozen_string_literal: true

module Discover
  # Base class providing a common interface for a Discover Penn "source"
  class Source
    class Error < StandardError; end

    # Used to get class for a source value as a symbol
    # @return [Discover::Source]
    def self.klass(source:)
      raise Error, "source #{source} has not been configured" unless source.to_sym.in?(Configuration::SOURCES)

      if source.to_sym.in?(Discover::Configuration::Blacklight::SOURCES)
        Discover::Source::Blacklight
      elsif source.to_sym.in?(Discover::Configuration::PSE::SOURCES)
        Discover::Source::PSE
      elsif source.to_sym.in?(Discover::Configuration::Database::SOURCES)
        Discover::Source::Database
      end
    end

    # @param [String] source
    # @return [Discover::Source]
    def self.create_source(source:)
      klass(source: source).new(source: source)
    end

    def initialize; end

    # Subclasses must implement #results, returning an iterable Discovery::Results object
    # @return [Discover::Results]
    def results(query:)
      raise NotImplementedError
    end

    # @return [Boolean]
    def blacklight?
      false
    end

    # @return [Boolean]
    def pse?
      false
    end

    # @return [Boolean]
    def database?
      false
    end

    # Defining connection logic here ensures consistent header values
    def connection(base_url:)
      Faraday.new(url: base_url, headers: { 'Content-Type': 'application/json',
                                            'User-Agent': Configuration::USER_AGENT }) do |connection|
        connection.response :raise_error
        connection.response :json
      end
    end

    private

    # @return [Object]
    def config_class
      @config_class ||= Discover::Configuration.config_for(source: source)
    end
  end
end
