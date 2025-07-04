# frozen_string_literal: true

module Inventory
  # Retrieves real time inventory data from Alma Availability API, making additional API requests depending on the type
  # of inventory it's handling.
  class List
    PHYSICAL = 'physical'
    ELECTRONIC = 'electronic'
    ECOLLECTION = 'ecollection'
    RESOURCE_LINK = 'resource_link'

    MAX_BIBS_GET = 100 # 100 is Alma API max
    DEFAULT_LIMIT = 3
    RESOURCE_LINK_LIMIT = 2

    class Error < StandardError; end

    class << self
      # Returns full inventory for a bib record.
      #
      # This method extracts all resource links for the MARC record and fetches additional inventory data from Alma.
      #
      # @param document [SolrDocument]
      # @return [Inventory::List::Response]
      def full(document)
        marc = from_marc document
        api = from_api document
        Response.new(entries: marc + api,
                     complete: true)
      rescue StandardError => e
        Honeybadger.notify(e)
        Response.new(entries: Array.wrap(marc) + Array.wrap(api),
                     complete: false)
      end

      # Returns a brief inventory for a bib record.
      #
      # This method extracts resource links from the MARC record and fetches additional inventory data from Alma. The
      # number of records returned are limited by defaults, but those can be customized if a different number of
      # results is desired.
      #
      # @param document [SolrDocument]
      # @param api_limit [Integer]
      # @param marc_limit [Integer]
      # @return [Inventory::List::Response]
      def brief(document, api_limit: DEFAULT_LIMIT, marc_limit: RESOURCE_LINK_LIMIT)
        marc = from_marc document, marc_limit
        api = from_api document, api_limit
        Response.new(entries: marc + api,
                     complete: true)
      rescue StandardError => e
        Honeybadger.notify(e)
        Response.new(entries: Array.wrap(marc) + Array.wrap(api),
                     complete: false)
      end

      # Get inventory entries stored in the document's MARC fields. By default limits the number of entries returned.
      #
      # @param document [SolrDocument]
      # @param limit [Integer]
      # @return [Inventory::List::Response]
      def resource_links(document, limit: RESOURCE_LINK_LIMIT)
        entries = from_marc(document, limit)

        Response.new(entries: entries, complete: true)
      end

      private

      # Returns inventory that cannot be extracted from the MARC document and has to be retrieved by making additional
      # Alma API calls.
      #
      # @param document [SolrDocument]
      # @param limit [Integer, nil]
      # @return [Array<Inventory::Entry>] returns entries
      def from_api(document, limit = nil)
        inventory_data = from_sru_availability(document.id)
        inventory_data += from_ecollections(document.id) if should_check_for_ecollections?(inventory_data)
        api_entries(inventory_data, document, limit: limit)
      end

      # Determine if we should check for Ecollections based on given inventory data - this may change.
      #
      # @note Can we know if a MMS ID is physical and skip this step? Physical items cannot have ecollections.
      # @param inventory_data [Array]
      # @return [Boolean, nil]
      def should_check_for_ecollections?(inventory_data)
        inventory_data&.none?
      end

      # Factory method to create Inventory::Entry objects.
      #
      # @param mms_id [String]
      # @param raw_data [Hash] single hash from array of inventory data
      # @return [Inventory::List::Entry::Base]
      def create_entry(mms_id, **raw_data)
        case raw_data[:inventory_type]&.downcase
        when PHYSICAL then Entry::Physical.new(mms_id: mms_id, **raw_data)
        when ELECTRONIC then Entry::Electronic.new(mms_id: mms_id, **raw_data)
        when ECOLLECTION then Entry::Ecollection.new(mms_id: mms_id, **raw_data)
        when RESOURCE_LINK then Entry::ResourceLink.new(**raw_data)
        else
          raise Error, "Type: '#{raw_data[:inventory_type]}' not found"
        end
      end

      # Grabs inventory data from Alma Bib Availability API. Returns only active entries if entries are electronic.
      #
      # @note this isn't currently in use as we've moved to using the SRU endpoint for availability lookups until the
      #       usual Alma API is fixed to work with BIBFRAME-cataloged records
      # @param mms_id [String]
      # @return [Array, nil]
      def from_availability(mms_id)
        data = Alma::Bib.get_availability([mms_id]).availability.dig(mms_id, :holdings)
        electronic_inventory?(data) ? only_available(data) : data
      end

      # Grabs inventory data from Alma SRU Availability API. Returns only active entries if entries are electronic.
      #
      # @param mms_id [String]
      # @return [Array, nil]
      def from_sru_availability(mms_id)
        data = AlmaSRU::Bib.get_availability(mms_id: mms_id).holdings.dig(mms_id, :holdings)
        electronic_inventory?(data) ? only_available(data) : data
      end

      # Returns entries that can be generated without making additional calls to Alma. Currently,
      # this only includes resources links available in the Bib MARC record.
      #
      # @param document [SolrDocument] document containing MARC with resource links
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::List::Entry::Base>]
      def from_marc(document, limit = nil)
        entries = limit ? document.marc_resource_links.first(limit) : document.marc_resource_links
        entries.map.with_index do |link_data, i|
          create_entry(document.id, inventory_type: RESOURCE_LINK, id: i, href: link_data[:link_url],
                                    description: link_data[:link_text])
        end
      end

      # Retrieve ECollection inventory data from Alma API calls
      #
      # @param mms_id [String]
      # @return [Array]
      def from_ecollections(mms_id)
        ecollections = Alma::Bib.get_ecollections mms_id
        return [] if ecollections.key? 'errorsExist'

        ecollections['electronic_collection']&.filter_map do |collection_hash|
          ecollection = Alma::Electronic.get(collection_id: collection_hash['id'])
          next unless ecollection

          hash = ecollection.data
          hash.merge({ 'inventory_type' => ECOLLECTION })
        end || []
      end

      # Sorts, limits and converts inventory information retrieved from SolrDocument and Alma into
      # Inventory::Entry objects.
      #
      # @param inventory_data [Array, nil] inventory data from API calls
      # @param document [SolrDocument]
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::List::Entry::Base>]
      def api_entries(inventory_data, document, limit: nil)
        sorted_data = Inventory::List::Sort::Factory.create(inventory_data).sort
        limited_data = sorted_data[0...limit] # limit entries prior to turning them into objects
        entries = limited_data.map do |data|
          create_entry(document.id, host_record_id: document.host_record_id, **data.symbolize_keys)
        end
        entries.select(&:displayable?)
      end

      # Return only available electronic holdings
      #
      # @param holdings [Array]
      # @return [Array]
      def only_available(holdings)
        holdings.select { |h| h['activation_status'] == Constants::ELEC_AVAILABLE }
      end

      # Check if inventory data is present and for electronic inventory
      #
      # @param inventory_data [Array<Hash>, nil]
      # @return [Boolean]
      def electronic_inventory?(inventory_data)
        return false unless inventory_data

        inventory_data.any? && inventory_data.first['inventory_type'].in?(Constants::ELECTRONIC_TYPES)
      end
    end
  end
end
