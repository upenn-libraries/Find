# frozen_string_literal: true

module Account
  # Show user fines and fees
  class FinesTableComponent < ViewComponent::Base
    attr_reader :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end

    # @return [Float]
    def total_fines
      return number_to_currency(0) unless alma_user

      number_to_currency(alma_user.total_fines)
    end

    private

    # @return [Alma::User, FalseClass]
    def alma_user
      @alma_user ||= user.alma_record
    end

    # @return [Alma::FineSet, nil]
    def fine_set
      return unless alma_user

      @fine_set ||= begin
        alma_user.fines
      rescue StandardError => _e
        nil
      end
    end
  end
end
