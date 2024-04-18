# frozen_string_literal: true

module Account
  # Show user details from Alma and Illiad
  class SettingsComponent < ViewComponent::Base
    attr_reader :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end

    # @return [String, nil]
    def alma_user_group
      return unless alma_user

      alma_user.user_group['desc']
    end

    # books by mail delivery address in two parts
    # @return [Array]
    def bbm_delivery_address
      return unless illiad_user

      illiad_user.bbm_delivery_address.join(' ').split('/')
    end

    private

    # @return [Alma::User, FalseClass]
    def alma_user
      @alma_user ||= user.alma_record
    end

    # @return [Illiad::User, FalseClass]
    def illiad_user
      @illiad_user ||= user.illiad_record
    end
  end
end
