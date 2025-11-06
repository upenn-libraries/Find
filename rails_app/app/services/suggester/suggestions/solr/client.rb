# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Establishes connection to solr server
      class Client
        attr_reader :uri, :params

        # @param url [String]
        # @param params [Hash]
        def initialize(url:, params:)
          @uri = URI.parse(url)
          @params = params
        end

        # @return [Hash]
        def response_body
          @response_body ||= response.body
        end

        private

        # @return [Faraday::Response]
        def response
          @response ||= connection.get(uri.path, params)
        rescue Faraday::Error => e
          Honeybadger.notify(e)
          raise Service::Error, "Failed to retrieve solr suggestions: #{e}"
        end

        # @return [Faraday::Connection]
        def connection
          @connection ||= Faraday.new(uri.to_s) do |conn|
            conn.request :authorization, :basic, uri.user, uri.password
            conn.response :json
            conn.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
          end
        end
      end
    end
  end
end
