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

        # alma will limit us to 100 items, so we need to handle that. i'm thinking that we should call with a limit of 100
        # and if we get 100 items back, we should set the offset to 100 and call again. we should keep doing this until we
        # get less than 100 items back. we should then return the items we have.
        item_set = fetch_all_items(mms_id: mms_id, holding_id: holding_id)
        return item_set if item_set.present?

        holdings = Alma::BibHolding.find_all(mms_id: mms_id)

        # TODO: implement boundwith support, see example mms_id: 9920306003503681
        # raise BoundwithError if holdings['holding'].blank?
        return [] if holdings['items'].blank?

        # Fake an item when a holding has no items, ugh
        [Inventory::Service::Item.new({
                                        'bib_data' => holdings['bib_data'],
                                        'holding_data' => holdings['holding']
                                                            &.find { |holding| holding['holding_id'] == holding_id },
                                        'item_data' => {}
                                      })]
      end

      private

      def self.fetch_all_items(mms_id:, holding_id:)
        item_set = Alma::BibItem.find(mms_id, holding_id: holding_id, limit: 100).items
        offset = 100
        while item_set.size == offset
          items = Alma::BibItem.find(mms_id, holding_id: holding_id, limit: 100, offset: offset).items
          item_set += items
          offset += 100
        end
        item_set
      end
    end
  end
end
