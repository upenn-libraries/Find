# frozen_string_literal: true

module Hathi
  # Service class to retrieve Hathi information for a given record (if it exists)
  class Service
    class << self
      # Returns the full record from the Hathi response. There are two primary keys, `records` and `items`.
      # @return [Hash]
      def record(identifiers:)
        return if identifiers.blank?

        response_data = hathi_response(identifiers)
        return unless response_data

        extract_record(response_data, identifiers)
      end

      private

      # @param [Array] identifiers
      # @return [Faraday::Connection]
      def client(identifiers)
        Faraday.new(url: request_url(identifiers)) do |config|
          config.request :json
          config.request :retry,
                         exceptions: retry_exceptions,
                         methods: ['get'],
                         interval: 1,
                         max: 3
          config.response :json
        end
      end

      # @param [Hash] identifiers
      # @return [Hash, nil]
      def hathi_response(identifiers)
        client(identifiers).get.body
      rescue Faraday::Error => e
        Honeybadger.notify(e)
      end

      # @param [Hash] response_data
      # @param [Hash] identifiers
      # @return [String, nil]
      def extract_record(response_data, identifiers)
        joined_ids = format_identifiers(identifiers)
        return unless joined_ids

        response_data[joined_ids]
      end

      # @param [Hash] identifiers
      # @return [String]
      def request_url(identifiers)
        "#{Settings.hathi.base_url}/#{format_identifiers(identifiers)}"
      end

      # @param [Hash] identifiers
      # @return [Array]
      def format_identifiers(identifiers)
        identifiers.filter_map { |type, value| "#{type}:#{value}" }.join(';')
      end

      # @return [Array]
      def retry_exceptions
        Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
      end
    end
  end
end
