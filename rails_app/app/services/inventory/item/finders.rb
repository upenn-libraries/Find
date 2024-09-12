# frozen_string_literal: true

module Inventory
  class Item
    # Class methods for lookup and instantiation of Items. Wraps Alma gem finders and BibItem class.
    module Finders
      # Get a single Item for a given mms_id, holding_id, and item_pid
      # @param mms_id [String] the Alma mms_id
      # @param holding_id [String] the Alma holding_id
      # @param item_id [String] the Alma item_pid
      # @option user_id [String, nil] the user id to get circ policy data
      # @return [Inventory::Item]
      def find(mms_id:, holding_id:, item_id:, user_id: nil)
        raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id && item_id

        item = Alma::BibItem.find_one(mms_id: mms_id, holding_id: holding_id, item_pid: item_id,
                                      options: { expand: 'due_date_policy', user_id: user_id }.compact_blank)
        new(item)
      end

      # Return an array of items for a given mms_id and holding_id, fake an item if a holding has no items
      # @param mms_id [String] the Alma mms_id
      # @param holding_id [String] the Alma holding_id
      # @param host_record_id [String, nil] the host_record_id if record is boundwith
      # @param location_code [String, nil] if the item is in a temp location, this is the location code so we can
      #                                    attempt to filter out the relevant items from the list of all items
      # @param user_id [String, nil] user_id to enrich items with due_date_policy value
      # @return [Array<Inventory::Item>]
      def find_all(mms_id:, holding_id:, host_record_id: nil, location_code: nil, user_id: nil)
        raise ArgumentError, 'No MMS ID provided' unless mms_id

        # Create and return an item to represent boundwith record.
        return [boundwith_item(mms_id, holding_id, host_record_id)] if host_record_id.present?

        # in most cases, we return the holding's items here
        item_set = build_item_set mms_id: mms_id, holding_id: holding_id, location_code: location_code, user_id: user_id
        return item_set if item_set.any?

        # if we have no items at this point, then Alma has no items in this holding. this is an unfortunate reality so
        # we fake an items based on this bib and holding details.
        holdings_data = Alma::BibHolding.find_all(mms_id: mms_id)

        raise 'Record has no holding.' if holdings_data['holding'].blank?

        [holding_as_item(holdings_data, holding_id)]
      end

      private

      # Build out Inventory::Item objects from Item API request data, filtering out items in cases where ALL items are
      # returned, and temp location items from their permanent holdings as they are rendered with their temp holding.
      # @param mms_id [String]
      # @param holding_id [String, nil]
      # @param location_code [String]
      # @param user_id [String, nil]
      # @return [Array<Inventory::Item>]
      def build_item_set(mms_id:, holding_id:, location_code:, user_id: nil)
        bib_items = fetch_all_items(mms_id: mms_id, holding_id: holding_id, user_id: user_id)
        item_set = bib_items.map { |bib_item| new(bib_item) }

        # if a holding id is not provided, we get _ALL_ items for the MMS ID. typically this occurs when a holding is in
        # a "temporary location". We attempt to filter the list of ALL items returned by the above lookup to include
        # only the items in the temporary location based on the location code value. Also, the Items API returns items
        # that might be in a temp location and are shown as distinct holdings in our view.
        if holding_id.blank? && location_code
          item_set.select { |i| i.in_temp_location? && (i.location.code == location_code) }
        else
          item_set.reject(&:in_temp_location?)
        end
      end

      # Boundwith records contain the relevant bibliographic information, but their host records contain the holding
      # and item information. In order to facilitate the fulfillment process we create an item that combines the
      # information from the host and child record.
      #
      # @param mms_id [String] the Alma mms_id
      # @param holding_id [String] the Alma holding_id
      # @param host_record_id [String] the host_record_id
      #  @return [Inventory::Item]
      def boundwith_item(mms_id, holding_id, host_record_id)
        # Fetch item for host record.
        item = Alma::BibItem.find(host_record_id, holding_id: holding_id).first

        # Extract bibliographic data from child record (record displayed in Find).
        keys = %w[title author issn isbn complete_edition network_numbers place_of_publication
                  date_of_publication publisher_const]
        bib_data = Alma::Bib.find([mms_id], {}).response['bib'].first.slice(*keys)

        # Combine information to create a frankenstein'd Item record that combines host record's holding and item
        # information with displayable record's bib data.
        new(Alma::BibItem.new({ 'bib_data' => bib_data.merge({ 'mms_id' => host_record_id }),
                                'holding_data' => item.holding_data,
                                'item_data' => item.item_data,
                                'boundwith' => true }))
      end

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

      # Fetch all items for a given mms_id and holding_id, optionally with a user_id specified
      # @param mms_id [String]
      # @param holding_id [String]
      # @param limit [Integer]
      # @param user_id [String, nil]
      # @return [Array<Alma::BibItem>]
      def fetch_all_items(mms_id:, holding_id:, limit: 100, user_id: nil)
        query_options = { limit: limit, order_by: 'description', direction: 'asc', expand: 'due_date_policy' }
        query_options[:user_id] = user_id if user_id.present?
        (1..).each_with_object([]) do |_, items|
          response = Alma::BibItem.find(mms_id, holding_id: holding_id, **query_options)
          items.push(*response.items)
          query_options[:offset] = (query_options[:offset].to_i || 0) + limit
          return items.flatten if response.total_record_count == items.length
        end
      end
    end
  end
end
