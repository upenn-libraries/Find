# frozen_string_literal: true

module Discover
  # Base class providing a common interface for a Discover Penn "source"
  class Source
    # Used to get class for a source value as a symbol
    # @return [Discover::Source]
    def self.klass(source:)
      raise unless source.to_sym.in?(Configuration::SOURCES)

      return Discover::Source::Blacklight if source.to_sym.in?(Discover::Configuration::Blacklight::SOURCES)

      Discover::Source::PSE if source.to_sym.in?(Discover::Configuration::PSE::SOURCES)
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

    # Defining connection logic here ensures consistent header values
    def connection(base_url:)
      Faraday.new(url: base_url, headers: { 'Content-Type': 'application/json',
                                            'User-Agent': Configuration::USER_AGENT }) do |connection|
        connection.response :raise_error
        connection.response :json
      end
    end
  end
end
