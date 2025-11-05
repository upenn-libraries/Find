# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Orchestrates requests to solr suggestion endpoint
      class Service
        # Custom error
        class Error < StandardError; end

        attr_reader :uri, :params

        PARAMS = %i[dictionary count build q].freeze

        def initialize(url:, params: {})
          @uri = URI.parse(url)
          @params = params.slice(*PARAMS)
          @config = config
        end

        delegate :completions, :data, to: :parsed_response

        private

        def parsed_response
          @parsed_response ||= Response.new(response: response,
                                            handler: request_handler,
                                            dictionary: dictionary,
                                            query: query)
        end

        def query
          params[:q]
        end

        def dictionary
          @dictionary ||= params[:dictionary] || Settings.suggester.suggestions.digital_catalog.solr.dictionary
        end

        def request_handler
          uri.path.split('/').last
        end

        def response
          connection.get(uri.path, params)
        rescue Faraday::Error => e
          Honeybadger.notify(e)
          raise Error, "Failed to retrieve solr suggestions: #{e}"
        end

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
