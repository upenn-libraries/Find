# frozen_string_literal: true

module Hathi
  # Service class to retrieve Hathi information for a given record (if it exists)
  class Service
    class << self
      # Returns the full record from the Hathi response. There are two primary keys, `records` and `items`.
      # @return [Hash]
      def record(identifier_map:)
        return if identifier_map.blank?

        response_data = hathi_response(identifier_map)
        return unless response_data

        extract_record(response_data, identifier_map)
      end

      private

      # @param [Array] identifier_map
      # @return [Faraday::Connection]
      def client(identifier_map)
        Faraday.new(url: request_url(identifier_map)) do |config|
          config.request :json
          config.request :retry,
                         exceptions: retry_exceptions,
                         methods: ['get'],
                         interval: 1,
                         max: 3
          config.response :json
        end
      end

      # @param [Hash] identifier_map
      # @return [Hash, nil]
      def hathi_response(identifier_map)
        client(identifier_map).get.body
      rescue Faraday::Error => e
        Honeybadger.notify(e)
      end

      # @param [Hash] response_data
      # @param [Hash] identifier_map
      # @return [String, nil]
      def extract_record(response_data, identifier_map)
        joined_ids = format_identifiers(identifier_map)
        return unless joined_ids

        response_data[joined_ids]
      end

      # @param [Hash] identifier_map
      # @return [String]
      def request_url(identifier_map)
        "#{Settings.hathi.base_url}/#{format_identifiers(identifier_map)}"
      end

      # @param [Hash] identifier_map
      # @return [Array]
      def format_identifiers(identifier_map)
        identifier_map.filter_map { |type, value| "#{type}:#{value}" }.join(';')
      end

      # @return [Array]
      def retry_exceptions
        Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
      end
    end
  end
end
