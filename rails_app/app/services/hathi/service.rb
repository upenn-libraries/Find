# frozen_string_literal: true

module Hathi
  # Service class to retrieve Hathi link for a given record (if it exists)
  class Service
    attr_reader :identifiers

    URL_PREFIX = 'https://catalog.hathitrust.org/api/volumes/brief/json'

    class HathiRequestError < StandardError; end

    def initialize(identifiers:)
      @identifiers = identifiers
    end

    # maybe one class method instead of instance method, not really necessary since we're making one call

    # @return [String, nil] URL from Hathi record if found
    def link
      return if identifiers.blank?

      response_data = fetch_hathi_data
      return unless response_data

      record_url(response_data)
    end

    def record
      # returns the hash of the whole hathi record, maybe some helper methods that access values in there
    end

    private

    def client
      @client ||= Faraday.new(url: request_url) do |config|
        config.request :json
        config.request :retry,
                       exceptions: retry_exceptions,
                       methods: ['get'],
                       interval: 1,
                       max: 3
        config.response :json
      end
    end

    # @return [Hash, nil] the Hathi response
    def fetch_hathi_data
      client.get.body
    rescue Faraday::Error => e
      Rails.logger.error("Hathi API request failed: #{e.message}")
      raise HathiRequestError, "Failed to fetch data from Hathi API: #{e.message}"
    end

    # @param [Hash] response_data
    # @return [String, nil] the record URL
    def record_url(response_data)
      identifier = matched_identifier(response_data)
      return unless identifier

      extract_record_url(response_data[identifier])
    end

    # @param [Hash] response_data
    # @return [String, nil] the first present matching ID
    def matched_identifier(response_data)
      formatted_identifiers.detect { |id| response_data.key?(id) }
    end

    # @param [Hash] data
    # @return [String, nil] the record URL
    def extract_record_url(data)
      records = data['records']
      return if records.blank?

      record = records.values&.first
      record&.fetch('recordURL', nil)
    end

    # @return [String] the URL to make a request to
    def request_url
      "#{URL_PREFIX}/#{formatted_identifiers.join(';')}"
    end

    # @return [Array] formatted IDs for the request URL
    # ["oclc:12345", "isbn:12345"]
    def formatted_identifiers
      @formatted_identifiers ||= identifiers.filter_map { |type, value| "#{type}:#{value}" }
    end

    # @return [Array] Faraday errors to retry on
    def retry_exceptions
      Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
    end
  end
end
