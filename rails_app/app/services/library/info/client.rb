# frozen_string_literal: true

module Library
  module Info
    # Provides a Faraday::Connection to perform requests
    class Client
      class << self
        def connection
          Faraday.new(url: base_url) do |config|
            # Sets the required credentials in the Authorization header
            config.headers[authorization_header] = "Bearer #{credential}"

            # Sets the Content-Type header to application/json on each request
            config.request :json

            # Adds retry logic
            config.request :retry, exceptions: exceptions_to_retry, methods: 'get', interval: 1, max: 3

            # Raises an error on 4xx and 5xx responses
            config.response :raise_error

            # Logs errors to the Rails logger, filtering out sensitive information
            config.response :logger, Rails.logger, headers: true, bodies: false, log_level: :info do |fmt|
              fmt.filter(/^(Authorization: ).*$/i, '\1[REDACTED]')
            end

            # Parses JSON response bodies, passing Faraday::ParsingError if invalid
            config.response :json
          end
        end

        # @overload get(url, params, headers)
        #   @param url [String]
        #   @param params [Hash]
        #   @param headers [Hash]
        def get(*args)
          connection.get(*args)
        end

        private

        # @return [String]
        def authorization_header
          'Authorization'
        end

        # @return [String]
        def base_url
          Settings.library.info.base_url
        end

        # @return [String]
        def credential
          Settings.library.info.api_key
        end

        # @return [Array]
        def exceptions_to_retry
          Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
        end
      end
    end
  end
end
