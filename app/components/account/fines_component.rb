# frozen_string_literal: true

module Account
  # Show user fines and fees
  class FinesComponent < ViewComponent::Base
    attr_reader :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end

    # @return [Float]
    def total_fines
      return 0.0 unless alma_user

      alma_user.total_fines
    end

    private

    # @return [Alma::User, FalseClass]
    def alma_user
      @alma_user ||= user.alma_record
    end
  end
end
