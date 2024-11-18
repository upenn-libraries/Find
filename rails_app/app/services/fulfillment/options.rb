# frozen_string_literal: true

module Fulfillment
  # Classes for classifying fulfillment options
  class Options
    # Base class for option categories
    class Category
      # Report the values of all constants explicitly defined in the class
      # @return [Array<Symbol>]
      def self.all
        constants(false).map(&method(:const_get))
      end
    end

    # Fulfillment options that involve delivering the item to the user, either as a physical object or a scan
    class Deliverable < Category
      ELECTRONIC = :electronic
      ILL_PICKUP = :ill_pickup
      MAIL = :mail
      OFFICE = :office
      PICKUP = :pickup
    end

    # Fulfillment options that involve the user coming to the item
    class Restricted < Category
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
