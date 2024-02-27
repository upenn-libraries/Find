# frozen_string_literal: true

module Inventory
  # Retrieves real time inventory data from Alma Availability API, making additional API requests depending on the type
  # of inventory it's handling.
  class Service
    MAX_BIBS_GET = 100 # 100 is Alma API max
    DEFAULT_LIMIT = 3

    class Error < StandardError; end

    class << self
      # Returns the whole inventory for a Bib record. It will extract resource links from the MARC record and fetch
      # additional inventory data from Alma. The number of records returned can be limited via a parameter.
      #
      # @param document [SolrDocument]
      # @param limit [Integer]
      # @return [Inventory::Response]
      def all(document, limit = DEFAULT_LIMIT)
        marc = from_marc(document, limit)
        api = from_api(document.id, limit)

        Inventory::Response.new(
          entries: marc[:entries] + api[:entries],
          remainder: marc[:remainder] + api[:remainder]
        )
      end

      # Get inventory entries stored in the document's MARC fields
      # @param document [SolrDocument]
      # @return [Inventory::Response]
      def resource_links(document, limit = nil)
        inventory = from_marc(document, limit)

        Inventory::Response.new(
          entries: inventory[:entries],
          remainder: inventory[:remainder]
        )
      end

      # def entry(mms_id, holding_id, portfolio_id)
      #   return FullEntry.new()
      # end
      #
      # # @return [Inventory::Entry]
      # def electronic_entry
      #   # call alma api(s) for portfolio/e-collection/service
      #   # collate data
      #   # create new object?
      #   # return hash
      #   {
      #     notes: '',
      #     call_number: '',
      #     link: '',
      #     coverage: '',
      #     more_data: ''
      #   }
      # end
      #
      # def physical_entry
      #
      # end
      #
      # def resource_entry
      #   # from marc
      # end

      # Retrieve real time availability of inventory from Alma
      # @todo if we're going to use this, it may need to be revised to receive SolrDocuments
      # @param mms_ids [Array<String>]
      # @param brief_count [Integer] limits how many inventory values we return
      # @return [Hash] hash with mms_id as top-level keys
      # def find_many(mms_ids, brief_count = 3)
      #   raise Error, "Too many MMS IDs provided, exceeds max allowed of #{MAX_BIBS_GET}." if mms_ids.size > MAX_BIBS_GET
      #
      #   availability_data = Alma::Bib.get_availability(mms_ids)
      #
      #   mms_ids.each_with_object({}) do |mms_id, result_hash|
      #     inventory_data = inventory_data(mms_id, availability_data)
      #     inventory = inventory(mms_id, inventory_data).map(&:to_h)
      #
      #     result_hash[mms_id.to_sym] = { inventory: inventory.first(brief_count), total: inventory.length }
      #   end
      # end

      private

      # Factory class method to create Inventory::Entry objects.
      #
      # @param mms_id [String]
      # @param raw_data [Hash] single hash from array of inventory data
      # @return [Inventory::Entry]
      def create_entry(mms_id, raw_data)
        case raw_data['inventory_type']&.downcase
        when Entry::PHYSICAL
          items = find_items(mms_id, raw_data['holding_id'])
          Inventory::Entry::Physical.new(mms_id, raw_data, items)
        when Entry::ELECTRONIC
          portfolio = find_portfolio(raw_data['portfolio_pid'], raw_data['collection_id'])
          # potentially make some other api calls here for e-collection or service info if we're unsatisfied with
          # portfolio data. It's probably best to place this logic in it's own method or class. Below are some of the
          # additional values of interest:
          # - get authentication notes / public notes when not found on portfolio
          # - get coverage when not found on availability data or portfolio
          # - get policy?
          # - are all of these relevant all the time? if some of this information is only relevant on show page then our
          # service needs a clean way of knowing when to make these potential additional requests
          Inventory::Entry::Electronic.new(mms_id, raw_data, { portfolio: portfolio })
        when Entry::RESOURCE_LINK
          Inventory::Entry::ResourceLink.new(**raw_data)
        else
          # when we're here we're dealing with a bib that doesn't have real time availability data (e.g. a collection)
          raise Error, "Type: '#{raw_data['inventory_type']}' not found"
        end
      end

      # Returns inventory that cannot be extracted from the MARC document and has to be retrieved by making additional
      # Alma API calls.
      #
      # @param mms_id [String]
      # @param limit [Integer, nil]
      # @return [Hash] returns hash containing entries and a number of remainder entries that are not included in the
      #                entries array
      def from_api(mms_id, limit)
        holdings = Alma::Bib.get_availability([mms_id]).availability.dig(mms_id, :holdings) # TODO: handle API error?
        entries = api_entries(holdings, mms_id, limit: limit)
        { entries: entries, remainder: holdings.length - entries.length }
      end

      # Returns entries that can be generated without making additional calls to Alma. Currently,
      # this only includes resources links available in the Bib MARC record.
      #
      # @param document [SolrDocument] document containing MARC with resource links
      # @param _limit [Integer, nil]
      # @return [Hash, nil]
      def from_marc(document, _limit) # find_resource_links
        entries = document.marc_resource_links.map do |link_data|
          create_entry(document.id, { type: RESOURCE_LINK, href: link_data[:link_url], description: link_data[:link_text] })
        end
        { entries: entries, remainder: 0 }
      end

      # Converts holdings information retrieved from Alma into Inventory::Entry objects.
      #
      # @param holdings [Array] holdings data from Availability API call
      # @param mms_id [String]
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::Entry>]
      def api_entries(holdings, mms_id, limit: nil)
        sorted_data = holdings # TODO: add sorting logic, e.g., .sort_by { |entry| some_complex_logic }
        limited_data = sorted_data[0..limit] # limit entries prior to turning them into objects
        limited_data.map { |data| create_entry(mms_id, data) }
      end

      # Retrieve item data for physical inventory
      #
      # @param mms_id [String]
      # @param holding_id [String]
      # @param options [Hash] additional parameters to pass to the request (e.g. limit, offset)
      # @note should we return the entire Alma::BibItemSet instead?
      # @return [Array<Alma::BibItem>] array of items
      def find_items(mms_id, holding_id, **options)
        default_options = { holding_id: holding_id, expand: 'due_date,due_date_policy' }
        resp = Alma::BibItem.find(mms_id, default_options.merge(options))
        resp.items
      end

      # Retrieve portfolio data for electronic inventory
      #
      # @param portfolio_id [String, Nil]
      # @param collection_id [String]
      # @param service_id [String, Nil]
      # @return [Hash]
      def find_portfolio(portfolio_id, collection_id = nil, service_id = nil)
        Alma::Electronic.get(collection_id: collection_id,
                             service_id: service_id,
                             portfolio_id: portfolio_id)&.data || {}
      end

      # Retrieve collection data for electronic inventory
      #
      # @param collection_id [String]
      # @return [Hash]
      def find_collection(collection_id)
        Alma::Electronic.get(collection_id: collection_id)&.data || {}
      end

      # Retrieve service data for electronic inventory
      #
      # @param collection_id [String]
      # @param service_id [String]
      # @return [Hash]
      def find_service(collection_id, service_id)
        Alma::Electronic.get(collection_id: collection_id, service_id: service_id)&.data || {}
      end
    end
  end
end
