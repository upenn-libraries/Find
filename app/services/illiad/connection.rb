# frozen_string_literal: true

module Illiad
  # Provides a Faraday::Connection to perform requests
  # @return [Faraday::Connection]
  module Connection
    # Establish Faraday connection with default values
    def faraday
      Faraday.new(url: base_url) do |config|
        # Sets the required credentials in the Authorization header
        config.request :authorization, authorization_field, credential
        # Sets the Content-Type header to application/json on each request.
        # Also, if the request body is a Hash, it will automatically be encoded as JSON.
        config.request :json
        # Retries request for certain exceptions
        config.request :retry, exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed],
                               methods: %i[get post patch delete], interval: 1, max: 3
        # Raises an error on 4xx and 5xx responses.
        config.response :raise_error
        # Use rails logger and filter out sensitive information
        config.response :logger, Rails.logger, headers: true, bodies: false, log_level: :info do |fmt|
          fmt.filter(/^(Authorization: ).*$/i, '\1[REDACTED]')
          # Parses JSON response bodies.
          # If the response body is not valid JSON, it will raise a Faraday::ParsingError.
          config.response :json
        end
      end
    end

    # @return [String]
    def secure_version_path
      '/SystemInfo/SecurePlatformVersion'
    end

    private

    # @return [Symbol]
    def authorization_field
      :''
    end

    # @return [String]
    def base_url
      ''
    end

    # @return [String]
    def credential
      ''
    end

    # Handle errors raised on bad responses
    # @param custom_error [Class<StandardError>]
    def rescue_errors(custom_error:)
    rescue Faraday::Error => e
      raise custom_error, "Illiad API error. #{error_messages(e)}".strip
    end

    # Retrieve error message and validation errors for bad (400) requests
    # @param error [Faraday::Error]
    # @return [String]
    def error_messages(error)
      error_message = error.response_body['Message']
      validation_errors = error.response_body['ModelState'].flat_map { |_field, value| value }.join(' ')

      "#{error_message} #{validation_errors}".strip
    end
  end
end
