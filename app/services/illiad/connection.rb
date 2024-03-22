# frozen_string_literal: true

module Illiad

  # Provides a Faraday::Connection to perform requests
  # @return [Faraday::Connection]
  module Connection
    include ApiDefaults

    # Establish Faraday connection with default values
    def faraday(options)
      Faraday.new(url: base_url, **options) do |config|
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
  end
end
