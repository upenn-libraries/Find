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

      # Recursively fetch all items for a given mms_id and holding_id
      # @param mms_id [String]
      # @param holding_id [String]
      # @param limit [Integer]
      # @param offset [Integer]
      # @param accumulated_items [Array<PennItem>]
      def self.fetch_all_items(mms_id:, holding_id:, limit: 100, offset: 0, accumulated_items: [])
        items = Alma::BibItem.find(mms_id, holding_id: holding_id, limit: limit, offset: offset).items
        accumulated_items += items

        # Base case: if the number of items returned is less than the limit, we've fetched all items
        return accumulated_items if items.size < limit

        # Recursive case: fetch the next batch of items
        fetch_all_items(mms_id: mms_id, holding_id: holding_id, limit: limit,
                        offset: offset + limit, accumulated_items: accumulated_items)
      rescue BibItemSet::ResponseError
        # If the total count of items is a multiple of 100, we'll get a ResponseError when calling for the next batch.
        # I don't love that this error is so non-specific, but this is a limitation of the Alma gem and the Alma API.
        accumulated_items
      end
      private_class_method :fetch_all_items
    end
  end
end
