# frozen_string_literal: true

module Account
  # Show user details from Alma and Illiad
  class SettingsComponent < ViewComponent::Base
    attr_reader :user

    delegate :email, :full_name, :ils_group_name, :bbm_delivery_address, :office_delivery_address, to: :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end
  end
end
