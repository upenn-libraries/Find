# frozen_string_literal: true

module Inventory
  # Retrieves real time inventory data from Alma Availability API, making additional API requests depending on the type
  # of inventory it's handling.
  class Service
    MAX_BIBS_GET = 100 # 100 is Alma API max
    DEFAULT_LIMIT = 3
    RESOURCE_LINK_LIMIT = 2

    class Error < StandardError; end

    class << self
      # Returns full inventory for a bib record.
      #
      # This method extracts all resources links for the MARC record and fetches additional inventory data from Alma.
      #
      # @param document [SolrDocument]
      # @return [Inventory::Response]
      def full(document)
        marc = from_marc(document, nil)
        api = from_api(document.id, nil)

        Inventory::Response.new(entries: marc + api)
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
      # @return [Inventory::Response]
      def brief(document, api_limit: DEFAULT_LIMIT, marc_limit: RESOURCE_LINK_LIMIT)
        marc = from_marc(document, marc_limit)
        api = from_api(document.id, api_limit)

        Inventory::Response.new(entries: marc + api)
      end

      # Get inventory entries stored in the document's MARC fields. By default limits the number of entries returned.
      #
      # @param document [SolrDocument]
      # @param limit [Integer, nil]
      # @return [Inventory::Response]
      def resource_links(document, limit: RESOURCE_LINK_LIMIT)
        entries = from_marc(document, limit)

        Inventory::Response.new(entries: entries)
      end

      # @param mms_id [String]
      # @param portfolio_id [String]
      # @param collection_id [String, nil]
      # @return [Inventory::ElectronicDetail]
      def electronic_detail(mms_id, portfolio_id, collection_id)
        Inventory::ElectronicDetail.new(
          mms_id: mms_id, portfolio_id: portfolio_id, collection_id: collection_id
        )
      end

      private

      # Factory method to create Inventory::Entry objects.
      #
      # @param mms_id [String]
      # @param raw_data [Hash] single hash from array of inventory data
      # @return [Inventory::Entry]
      def create_entry(mms_id, raw_data)
        case raw_data[:inventory_type]&.downcase
        when Entry::PHYSICAL
          Inventory::Entry::Physical.new(mms_id: mms_id, **raw_data)
        when Entry::ELECTRONIC
          Inventory::Entry::Electronic.new(mms_id: mms_id, **raw_data)
        when Entry::RESOURCE_LINK then Inventory::Entry::ResourceLink.new(**raw_data)
        else
          raise Error, "Type: '#{raw_data[:inventory_type]}' not found"
        end
      end

      # Returns inventory that cannot be extracted from the MARC document and has to be retrieved by making additional
      # Alma API calls.
      #
      # @param mms_id [String]
      # @param limit [Integer, nil]
      # @return [Array<Inventory::Entry>] returns entries
      def from_api(mms_id, limit)
        inventory = gather_api_inventory mms_id: mms_id
        inventory = only_available(inventory) if are_electronic?(inventory)
        api_entries(inventory, mms_id, limit: limit)
      end

      # Returns entries that can be generated without making additional calls to Alma. Currently,
      # this only includes resources links available in the Bib MARC record.
      #
      # @param document [SolrDocument] document containing MARC with resource links
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::Entry>]
      def from_marc(document, limit)
        entries = limit ? document.marc_resource_links.first(limit) : document.marc_resource_links
        entries.map.with_index do |link_data, i|
          create_entry(document.id, { inventory_type: Inventory::Entry::RESOURCE_LINK, id: i,
                                      href: link_data[:link_url], description: link_data[:link_text] })
        end
      end

      # Sorts, limits and converts inventory information retrieved from Alma into Inventory::Entry objects.
      #
      # @param inventory_data [Array] inventory data from Availability API call
      # @param mms_id [String]
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::Entry>]
      def api_entries(inventory_data, mms_id, limit: nil)
        sorted_data = Inventory::Sort::Factory.create(inventory_data).sort
        limited_data = sorted_data[0...limit] # limit entries prior to turning them into objects
        limited_data.map { |data| create_entry(mms_id, data.symbolize_keys) }
      end

      # Return only available electronic holdings
      # @param holdings [Array]
      # @return [Array]
      def only_available(holdings)
        holdings.select { |h| h['activation_status'] == Constants::ELEC_AVAILABLE }
      end

      # Is the holdings data of the electronic type?
      # @param holdings [Array]
      # @return [Boolean]
      def are_electronic?(holdings)
        return false unless holdings.any?

        holdings.first['inventory_type'] == Entry::ELECTRONIC
      end

      # @param mms_id [String]
      # @return [null]
      def gather_api_inventory(mms_id:)
        holdings = Alma::Bib.get_availability([mms_id]).availability.dig(mms_id, :holdings)
        return holdings if holdings.any? && are_electronic?(holdings)

        # There is some confusion about whether we need to _ALWAYS_ check for ecollections - even if portfolios or
        # entries are returned. Franklin only checks for ecollections if the availability call returns no portfolios,
        # so let's do that for now.
        return holdings unless holdings.empty?

        holdings + ecollection_inventory(mms_id)
      end

      # Some electronic records have inventory as "E-Collection" records, which are not returned in the availability
      # call. In this case, we check the Bib record for associated collections and shim them into a hash that can be
      # used to build out an electronic inventory entry.
      # @param mms_id [String]
      # @return [Array, Array<Hash>]
      def ecollection_inventory(mms_id)
        ecollections = Alma::Bib.get_ecollections mms_id
        return [] if ecollections.key? 'errorsExist'

        ecollections['electronic_collection'].map.with_index { |collection_hash, index|
          ecollection = Alma::Electronic.get(collection_id: collection_hash['id'])
          hash = ecollection_to_hash(ecollection, index)
          next if hash['url'].blank? # Don't show an entry if we don't have a URL

          hash
        }.compact_blank
      end

      # Convert an Alma Collection object into a hash of data that can be used to build an electronic inventory entry
      # @param collection [Alma::Electronic::Collection]
      # @param index [Integer]
      # @return [Hash{Symbol->String (frozen)}]
      def ecollection_to_hash(collection, index)
        { 'portfolio_pid' => "ecollection_#{index + 1}",
          'collection_id' => collection['id'],
          'activation_status' => Inventory::Constants::AVAILABLE.capitalize,
          'library_code' => collection.dig('library', 'value'),
          'collection' => collection['public_name_override'].presence || collection['public_name'].presence || 'Online',
          'coverage_statement' => '', # ecollections API doesn't return coverage
          'interface_name' => collection.dig('interface', 'name'),
          'url' => collection['url_override'].presence || collection['url'],
          'inventory_type' => Inventory::Entry::ELECTRONIC }
      end
    end
  end
end
