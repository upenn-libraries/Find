# frozen_string_literal: true

Alma.configure do |config|
  config.apikey = Settings.alma.api_key

  # Default enable_loggable is set to false
  config.enable_loggable = Rails.env.development?

  # Default timeout is set to 5 seconds; can only provide integers
  # NOTE: during periods of Alma API service interruptions, a longer timeout can lead to a lot of
  # waiting connections that can end up blocking new connections.
  # config.timeout = 10
end
