# frozen_string_literal: true

module Inventory
  # Extend the Inventory::Service to include physical item data
  class Service
    # Retrieves Alma physical item data
    class Physical
      class BoundwithError < StandardError; end

      # Get a single Item for a given mms_id, holding_id, and item_pid
      # @params mms_id [String] the Alma mms_id
      # @params holding_id [String] the Alma holding_id
      # @params item_pid [String] the Alma item_pid
      # @return [PennItem]
      def self.item(mms_id:, holding_id:, item_pid:)
        raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id && item_pid

        item = Alma::BibItem.find_one(mms_id: mms_id, holding_id: holding_id, item_pid: item_pid).item
        Inventory::Service::Item.new(item)
      end

      # Return an array of PennItems for a given mms_id and holding_id, fake an item if a holding has no items
      # @params mms_id [String] the Alma mms_id
      # @params holding_id [String] the Alma holding_id
      # @return [Array<PennItem>]
      def self.items(mms_id:, holding_id:)
        raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

        item_set = Alma::BibItem.find(mms_id, holding_id: holding_id).items
        return item_set if item_set.present?

        holdings = Alma::BibHolding.find_all(mms_id: mms_id)

        # TODO: implement boundwith support, see example mms_id: 9920306003503681
        raise BoundwithError if holdings['holding'].blank?

        # Fake an item when a holding has no items, ugh
        [Inventory::Service::Item.new({
                                        'bib_data' => holdings['bib_data'],
                                        'holding_data' => holdings['holding']
                                                            &.find { |holding| holding['holding_id'] == holding_id },
                                        'item_data' => {}
                                      })]
      end
    end
  end
end