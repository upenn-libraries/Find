# frozen_string_literal: true

module Discover
  module Harvester
    # Establishes connection with penn museum server
    class Connection
      class Error < StandardError; end

      # @param base_url [URI::HTTPS, String]
      def initialize(base_url:)
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

      # @return [Faraday::Connection]
      def connection
        @connection ||= Faraday.new(@base_url, headers: { 'User-Agent': Configuration::USER_AGENT }) do |conn|
          conn.response :raise_error
        end
      end
    end
  end
end
