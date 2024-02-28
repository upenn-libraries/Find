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
      def all(document, limit: DEFAULT_LIMIT)
        marc = from_marc(document, limit)
        api = from_api(document.id, limit)

        Inventory::Response.new(entries: marc + api)
      end

      # Get inventory entries stored in the document's MARC fields
      # @param document [SolrDocument]
      # @param limit [Integer, nil]
      # @return [Inventory::Response]
      def resource_links(document, limit = nil)
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

      # Factory class method to create Inventory::Entry objects.
      #
      # @param mms_id [String]
      # @param raw_data [Hash] single hash from array of inventory data
      # @return [Inventory::Entry]
      def create_entry(mms_id, raw_data)
        case raw_data[:inventory_type]&.downcase
        when Entry::PHYSICAL
          Inventory::Entry::Physical.new(mms_id, raw_data)
        when Entry::ELECTRONIC
          # potentially make some other api calls here for e-collection or service info if we're unsatisfied with
          # portfolio data. It's probably best to place this logic in it's own method or class. Below are some of the
          # additional values of interest:
          # - get authentication notes / public notes when not found on portfolio
          # - get coverage when not found on availability data or portfolio
          # - get policy?
          # - are all of these relevant all the time? if some of this information is only relevant on show page then our
          # service needs a clean way of knowing when to make these potential additional requests
          Inventory::Entry::Electronic.new(mms_id, raw_data)
        when Entry::RESOURCE_LINK then Inventory::Entry::ResourceLink.new(**raw_data)
        else
          # when we're here we're dealing with a bib that doesn't have real time availability data (e.g. a collection)
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
        holdings = Alma::Bib.get_availability([mms_id]).availability.dig(mms_id, :holdings) # TODO: handle API error?
        api_entries(holdings, mms_id, limit: limit)
      end

      # Returns entries that can be generated without making additional calls to Alma. Currently,
      # this only includes resources links available in the Bib MARC record.
      #
      # @param document [SolrDocument] document containing MARC with resource links
      # @param _limit [Integer, nil]
      # @return [Array<Inventory::Entry>]
      def from_marc(document, _limit)
        document.marc_resource_links.map do |link_data|
          create_entry(document.id, { inventory_type: Inventory::Entry::RESOURCE_LINK,
                                      href: link_data[:link_url], description: link_data[:link_text] })
        end
      end

      # Converts holdings information retrieved from Alma into Inventory::Entry objects.
      #
      # @param holdings [Array] holdings data from Availability API call
      # @param mms_id [String]
      # @param limit [Integer, nil] limit number of returned objects
      # @return [Array<Inventory::Entry>]
      def api_entries(holdings, mms_id, limit: nil)
        sorted_data = holdings # TODO: add sorting logic, e.g., .sort_by { |entry| some_complex_logic }
        limited_data = sorted_data[0...limit] # limit entries prior to turning them into objects
        limited_data.map { |data| create_entry(mms_id, data.symbolize_keys) }
      end
    end
  end
end
