# frozen_string_literal: true

module Inventory
  class Item
    # Class methods for lookup and instantiation of Items. Wraps Alma gem finders and BibItem class.
    module Finders
      # Get a single Item for a given mms_id, holding_id, and item_pid
      # @param mms_id [String] the Alma mms_id
      # @param holding_id [String] the Alma holding_id
      # @param item_id [String] the Alma item_pid
      # @return [Inventory::Item]
      def find(mms_id:, holding_id:, item_id:)
        raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id && item_id

        item = Alma::BibItem.find_one(mms_id: mms_id, holding_id: holding_id, item_pid: item_id)
        new(item)
      end

      # Return an array of items for a given mms_id and holding_id, fake an item if a holding has no items
      # @param mms_id [String] the Alma mms_id
      # @param holding_id [String] the Alma holding_id
      # @return [Array<Inventory::Item>]
      def find_all(mms_id:, holding_id:)
        raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

        bib_items = fetch_all_items(mms_id: mms_id, holding_id: holding_id)
        item_set = bib_items.map { |bib_item| new(bib_item) }
        return item_set if item_set.present?

        holdings_data = Alma::BibHolding.find_all(mms_id: mms_id)

        # TODO: implement boundwith support, see example mms_id: 9920306003503681
        return [] if holdings_data['holding'].blank?

        # Fake an item when a holding has no items
        [holding_as_item(holdings_data, holding_id)]
      end

      private

      # Some of our records have no Items. In order for consistent logic in requesting contexts, we need an Item object
      # in all cases, so we build an Item object using data from the holding that will suffice for requesting purposes.
      # @param [Hash] holdings_data
      # @return [Inventory::Item]
      def holding_as_item(holdings_data, holding_id)
        new(Alma::BibItem.new(
              { 'bib_data' => holdings_data['bib_data'],
                'holding_data' => holdings_data['holding']&.find { |holding| holding['holding_id'] == holding_id },
                'item_data' => {} }
            ))
      end

      # Recursively fetch all items for a given mms_id and holding_id
      # @param mms_id [String]
      # @param holding_id [String]
      # @param limit [Integer]
      # @param offset [Integer]
      # @param accumulated_items [Array<Alma::BibItem>]
      # @return [Array<Alma::BibItem>]
      def fetch_all_items(mms_id:, holding_id:, limit: 100, offset: 0, accumulated_items: [])
        query_options = { limit: limit, offset: offset, order_by: 'description', direction: 'asc' }
        response = Alma::BibItem.find(mms_id, holding_id: holding_id, **query_options)
        accumulated_items += response.items

        # Base case: if the number of items returned is less than the limit, we've fetched all items
        return accumulated_items if response.total_record_count == accumulated_items.count

        # Recursive case: fetch the next batch of items
        fetch_all_items(mms_id: mms_id, holding_id: holding_id, limit: limit,
                        offset: offset + limit, accumulated_items: accumulated_items)
      end
    end
  end
end
