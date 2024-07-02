# frozen_string_literal: true

module Fulfillment
  # Class that mimics a User object. Used when proxying requests for users that are not logged in.
  class User
    include AlmaUser
    include IlliadUser

    attr_reader :uid

    def initialize(uid)
      @uid = uid
    end

    def ils_group
      @ils_group ||= alma_record.user_group['value']
    end
  end
end