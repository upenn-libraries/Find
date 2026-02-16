# frozen_string_literal: true

module Discover
  module Harvester
    class PennMuseum
      # Establishes connection with penn museum server
      class Connection
        class Error < StandardError; end

        def initialize(base_url: URI::HTTPS.build(host: Settings.discover.source.penn_museum.host))
          @base_url = base_url
        end

        # @param path [String]
        # @param headers [Hash]
        # @param block [Proc]
        # @return [Faraday::Response]
        def get(path, headers: {}, &block)
          connection.get(path, nil, headers, &block)
        end

        private

        def connection
          @connection ||= Faraday.new(@base_url, headers: { 'User-Agent': Configuration::USER_AGENT }) do |conn|
            conn.response :raise_error
          end
        end
      end
    end
  end
end
