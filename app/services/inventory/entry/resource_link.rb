# frozen_string_literal: true

module Inventory
  class Entry
    # Represents an inventory entry that comes from the MARC record
    class ResourceLink < Inventory::Entry
      attr_reader :href, :description, :type

      # @param inventory_type [Object]
      # @param href [String]
      # @param description [String]
      def initialize(inventory_type:, href:, description:)
        @href = href
        @description = description.strip
        @type = inventory_type
      end

      # @return [nil]
      def count
        nil
      end

      # @return [String]
      def location
        'Online'
      end

      # @return [String]
      def status
        'available'
      end
    end
  end
end
