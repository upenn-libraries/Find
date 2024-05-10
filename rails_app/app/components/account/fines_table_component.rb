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
      return number_to_currency(0) unless user.alma_record

      number_to_currency(user.alma_record.total_fines)
    end

    private

    # @return [Alma::FineSet, nil]
    def fine_set
      return unless user.alma_record

      @fine_set ||= begin
        user.alma_record.fines
      rescue StandardError => _e
        nil
      end
    end
  end
end
