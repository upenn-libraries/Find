# frozen_string_literal: true

module Fulfillment
  # Class that mimics a User object. Used when proxying requests for users that are not logged in.
  class User
    include AlmaAccount
    include IlliadAccount

    attr_reader :uid

    # @param [String] uid
    def initialize(uid)
      @uid = uid
    end

    # @return [String, nil]
    def email
      alma_preferred_email
    end

    # @return [String, nil]
    def ils_group
      return unless alma_record?

      @ils_group ||= alma_record.user_group['value']
    end
  end
end
