# frozen_string_literal: true

module Account
  # Show user details from Alma and Illiad
  class SettingsComponent < ViewComponent::Base
    attr_reader :user

    delegate :email, to: :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end

    # @return [String, nil]
    def full_name
      return unless user.alma_record

      user.alma_record.full_name
    end

    # @return [String, nil]
    def alma_user_group
      return unless user.alma_record?

      user.alma_record.user_group['desc']
    end

    # books by mail delivery address in two parts
    # @return [Array<String>, nil]
    def bbm_delivery_address
      return unless user.illiad_record

      user.illiad_record.bbm_delivery_address.join(' ').split('/').compact_blank
    end
  end
end
