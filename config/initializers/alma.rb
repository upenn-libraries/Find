# frozen_string_literal: true

Alma.configure do |config|
  # You have to set the apikey
  config.apikey = Rails.application.credentials.alma_api_key
  # Alma gem defaults to querying Ex Libris's North American API servers. You can override that here.
  config.region = 'https://api-eu.hosted.exlibrisgroup.com'

  # By default enable_loggable is set to false
  config.enable_loggable = false

  # By default timeout is set to 5 seconds; can only provide integers
  config.timeout = 10
end
