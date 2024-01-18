# frozen_string_literal: true

module Inventory
  # Retrieves inventory from Alma real time availability api
  class Service
    MAX_BIBS_GET = 100 # 100 is Alma API max
    PHYSICAL = 'physical'
    ELECTRONIC = 'electronic'

    class Error < StandardError; end
    class << self
      # Retrieve real time availability of single inventory resource from Alma
      # @param [String] mms_id single mms_id
      # @param [Integer] brief_count
      # @return [Hash]
      def find(mms_id, brief_count = 3)
        availability_data = Alma::Bib.get_availability([mms_id])
        inventory = inventory(mms_id, inventory_data(mms_id, availability_data)).map(&:to_h)
        { inventory: inventory.first(brief_count), total: inventory.length }
      end

      # Retrieve real time availability of inventory from Alma
      # @param [Array<String>] mms_ids
      # @param [Integer] brief_count
      # @return [Hash] hash with mms_id as top-level keys
      def find_many(mms_ids, brief_count = 3)
        raise Error, "Too many MMS IDs provided, exceeds max allowed of #{MAX_BIBS_GET}." if mms_ids.size > MAX_BIBS_GET

        availability_data = Alma::Bib.get_availability(mms_ids)

        mms_ids.each_with_object({}) do |mms_id, result_hash|
          inventory_data = inventory_data(mms_id, availability_data)
          inventory = inventory(mms_id, inventory_data).map(&:to_h)

          result_hash[mms_id.to_sym] = { inventory: inventory.first(brief_count), total: inventory.length }
        end
      end

      # Factory class method to create Inventory subclasses
      def create(type, mms_id, raw_api_data)
        case type&.downcase
        when PHYSICAL
          Inventory::Physical.new(mms_id, raw_api_data)
        when ELECTRONIC
          # potentially make some other api calls here for e-collection or service info
          Inventory::Electronic.new(mms_id, raw_api_data)
        else
          raise Error, "Type: #{type} not found"
        end
      end

      private

      # @param [String] mms_id
      # @param [Alma::AvailabilityResponse] availability_data
      # @return [Array<Hash>]
      def inventory_data(mms_id, availability_data)
        availability_data.availability.dig(mms_id, :holdings)
      end

      # @param [String] mms_id
      # @param [Array<Hash>] inventory_data
      # @return [Array<Inventory::Base>]
      def inventory(mms_id, inventory_data)
        inventory_data.map do |data|
          create(data['inventory_type'], mms_id, data)
        end
      end
    end
  end
end
