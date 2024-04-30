# frozen_string_literal: true

Alma.configure do |config|
  # You have to set the apikey
  config.apikey = Settings.alma.api_key

  # By default enable_loggable is set to false
  config.enable_loggable = false

  # By default timeout is set to 5 seconds; can only provide integers
  config.timeout = 10
end
