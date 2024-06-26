# frozen_string_literal: true

module Illiad
  # Provides a Faraday::Connection to perform requests
  class Client
    class Error < StandardError; end

    ERROR_MESSAGE = 'Illiad Api Error.'
    HTTP_METHODS = %i[get post patch].freeze

    # Establish Faraday connection with default values
    # @return [Faraday::Connection]
    class << self
      def connection
        Faraday.new(url: base_url) do |config|
          # Sets the required credentials in the Authorization header
          config.headers[authorization_header] = credential
          # Sets the Content-Type header to application/json on each request.
          # Also, if the request body is a Hash, it will automatically be encoded as JSON.
          config.request :json
          # Retries request for certain exceptions
          config.request :retry, exceptions: exceptions_to_retry, methods: HTTP_METHODS, interval: 1, max: 3
          # Raises an error on 4xx and 5xx responses.
          config.response :raise_error
          # Use rails logger and filter out sensitive information
          config.response :logger, Rails.logger, headers: true, bodies: false, log_level: :info do |fmt|
            fmt.filter(/^(#{authorization_header}: ).*$/i, '\1[REDACTED]')
          end
          # Parses JSON response bodies.
          # If the response body is not valid JSON, it will raise a Faraday::ParsingError.
          config.response :json
        end
      end

      # @overload get(url, params, headers)
      #   positional arguments to pass to Faraday get request
      #   @param url [String]
      #   @param params [Hash]
      #   @param headers [Hash]
      def get(*args)
        connection.get(*args)
      rescue Faraday::Error => e
        raise Error, error_messages(error: e)
      end

      # @overload post(url, body, headers)
      #   positional arguments to pass to Faraday post request
      #   @param url [String]
      #   @param body [Hash]
      #   @param headers [Hash]
      def post(*args)
        connection.post(*args)
      rescue Faraday::Error => e
        raise Error, error_messages(error: e)
      end

      # @overload patch(url, body, headers)
      #   positional arguments to pass to Faraday patch request
      #   @param url [String]
      #   @param body [Hash]
      #   @param headers [Hash]
      def patch(*args)
        connection.patch(*args)
      rescue Faraday::Error => e
        raise Error, error_messages(error: e)
      end

      # @overload put(url, body, headers)
      #   positional arguments to pass to Faraday put request
      #   @param url [String]
      #   @param body [Hash]
      #   @param headers [Hash]
      def put(*args)
        connection.put(*args)
      rescue Faraday::Error => e
        raise Error, error_messages(error: e)
      end

      # Retrieve error messages from body of bad responses
      # @return [String]
      def error_messages(error:)
        return ERROR_MESSAGE if error.response_body.blank?

        error_message = error.response_body&.dig('Message')
        validation_errors = error.response_body&.dig('ModelState')&.flat_map { |_field, value| value }&.join(' ')

        "#{ERROR_MESSAGE} #{error_message} #{validation_errors}".strip
      end

      private

      # @return [String]
      def authorization_header
        'Apikey'
      end

      # @return [String]
      def base_url
        Settings.illiad.base_url
      end

      # @return [String]
      def credential
        Settings.illiad.api_key
      end

      # @return [Array]
      def exceptions_to_retry
        Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
      end
    end
  end
end
