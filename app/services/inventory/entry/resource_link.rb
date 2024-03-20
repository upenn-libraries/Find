# frozen_string_literal: true

module Inventory
  class Entry
    # Represents an inventory entry that comes from the MARC record
    class ResourceLink < Inventory::Entry
      ID_PREFIX = 'resource_link_'

      attr_reader :href, :description, :type, :id

      # @param inventory_type [String]
      # @param href [String]
      # @param description [String]
      # @param id [String]
      def initialize(inventory_type:, href:, description:, id:)
        @href = href
        @description = description.strip
        @type = inventory_type
        @id = "#{ID_PREFIX}#{id}"
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
        Inventory::Constants::AVAILABLE
      end
    end
  end
end
