# frozen_string_literal: true

module Hathi
  # Service class to make requests to Hathi API, return URL from API if present
  class Service
    attr_accessor :identifiers

    HATHI_URL_PREFIX = 'https://catalog.hathitrust.org/api/volumes/brief/json'

    def initialize(identifiers:)
      @identifiers = identifiers
    end

    # @return [String, nil]
    def url
      return if identifiers.blank?

      "#{HATHI_URL_PREFIX}/#{hathi_params}"
    end

    # @return [Hash, nil]
    def response
      return unless url

      response = Faraday.get(url)
      JSON.parse(response.body)
    end

    # @return [String, nil]
    def link
      return unless present_in_hathi?

      # hathi_id = response['items']&.first&.[]('fromrecord')
      # response['records'][hathi_id]['recordurl']
      #
    end

    private

    def hathi_params
      identifiers.filter_map { |k, v|
        "#{k}:#{v}"
      }.join(';')
    end

    # @return [TrueClass, FalseClass]
    def present_in_hathi?
      response['records'].present?
    end
  end
end
