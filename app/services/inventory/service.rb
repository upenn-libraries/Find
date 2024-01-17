# frozen_string_literal: true

module Inventory
  # Retrieves inventory from Alma real time availability api
  class Service
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
      def find(mms_id, _brief_count = 3)
        availability_data = Alma::Bib.get_availability([mms_id])
        holdings(mms_id, holding_data(mms_id, availability_data)).map(&:to_h)
      end

      def find_many; end

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
