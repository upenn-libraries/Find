# frozen_string_literal: true

module Illiad
  # Default values used when making requests to Illiad
  module ApiDefaults
    # @return [Symbol]
    def authorization_field
      :''
    end

    # @return [String]
    def credential
      ''
    end

    # @return [String]
    def base_url
      ''
    end

    # @return [String]
    def secure_version_path
      '/SystemInfo/SecurePlatformVersion'
    end
  end
end
