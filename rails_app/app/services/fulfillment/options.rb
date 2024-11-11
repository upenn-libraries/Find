# frozen_string_literal: true

module Fulfillment
  class Options
    # Fulfillment options that involve delivering the item to the user, either as a physical object or a scan
    class Deliverable
      ELECTRONIC = :electronic
      ILL_PICKUP = :ill_pickup
      MAIL = :mail
      OFFICE = :office
      PICKUP = :pickup
    end

    # Fulfillment options that involve the user coming to the item
    class Restricted
      AEON = :aeon
      ARCHIVES = :archives
      HSP = :hsp
      ONSITE = :onsite
      REFERENCE = :reference
      RESERVES = :reserves
    end

    # The fulfillment anti-option
    UNAVAILABLE = :unavailable
  end
end
