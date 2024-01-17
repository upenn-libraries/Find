# frozen_string_literal: true

module Inventory
  # Retrieves inventory from Alma real time availability api
  class Service
    MAX_BIBS_GET = 100 # 100 is Alma API max
    class Error < StandardError; end
    class << self

      # Retrieve real time availability of single inventory resource from Alma
      # @param [String] mms_id
      # @param [Integer] brief_count
      # @return [Array<Hash>]
      def find(mms_id, brief_count = 3)
        availability_data = Alma::Bib.get_availability([mms_id])
        inventory(mms_id, inventory_data(mms_id, availability_data)).map(&:to_h).first(brief_count)
      end

      # Retrieve real time availability of inventory from Alma
      # @param [Array<String>] mms_ids
      # @param [Integer] brief_count
      # @return [Array<Hash>]
      def find_many(mms_ids, brief_count = 3)
        raise Error, "Too many MMS IDs provided, exceeds max allowed of #{MAX_BIBS_GET}." if mms_ids.size > MAX_BIBS_GET

        availability_data = Alma::Bib.get_availability(mms_ids)

        mms_ids.map do |mms_id|
          inventory_data  = inventory_data(mms_id, availability_data)
          { mms_id.to_sym => { inventory: inventory(mms_id, inventory_data).map(&:to_h).first(brief_count) } }
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
      # @return [Array<Holdings::Holding>]
      def inventory(mms_id, inventory_data)
        inventory_data.map do |data|
          Inventory::Holding.new(mms_id, data)
        end
      end
    end
  end
end
