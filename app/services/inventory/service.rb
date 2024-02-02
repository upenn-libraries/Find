# frozen_string_literal: true

module Inventory
  # Retrieves real time inventory data from Alma Availability API, making additional API requests depending on the type
  # of inventory it's handling.
  class Service
    MAX_BIBS_GET = 100 # 100 is Alma API max
    PHYSICAL = 'physical'
    ELECTRONIC = 'electronic'

    class Error < StandardError; end
    class << self
      # Retrieve real time availability of single inventory resource from Alma
      # @param [String] mms_id single mms_id
      # @param [Integer] brief_count limits how many inventory values we return
      # @return [Hash]
      def find(mms_id, brief_count = 3)
        availability_data = Alma::Bib.get_availability([mms_id])
        inventory = inventory(mms_id, inventory_data(mms_id, availability_data)).map(&:to_h)
        { inventory: inventory.first(brief_count), total: inventory.length }
      end

      # Retrieve real time availability of inventory from Alma
      # @param [Array<String>] mms_ids
      # @param [Integer] brief_count limits how many inventory values we return
      # @return [Hash] hash with mms_id as top-level keys
      def find_many(mms_ids, brief_count = 3)
        raise Error, "Too many MMS IDs provided, exceeds max allowed of #{MAX_BIBS_GET}." if mms_ids.size > MAX_BIBS_GET

        availability_data = Alma::Bib.get_availability(mms_ids)

        mms_ids.each_with_object({}) do |mms_id, result_hash|
          inventory_data = inventory_data(mms_id, availability_data)
          inventory = inventory(mms_id, inventory_data).map(&:to_h)

          result_hash[mms_id.to_sym] = { inventory: inventory.first(brief_count), total: inventory.length }
        end
      end

      # Factory class method to create Inventory subclasses
      # @param[String] type type of inventory
      # @param[String] mms_id
      # @param[Hash] raw_availability_data single hash from array of inventory data
      # @return[Inventory::Base]
      def create(type, mms_id, raw_availability_data)
        case type&.downcase
        when PHYSICAL
          items = find_items(mms_id, raw_availability_data['holding_id'])
          Inventory::Physical.new(mms_id, raw_availability_data, items)
        when ELECTRONIC
          portfolio = find_portfolio(raw_availability_data['portfolio_pid'], raw_availability_data['collection_id'])
          # potentially make some other api calls here for e-collection or service info if we're unsatisfied with
          # portfolio data. It's probably best to place this logic in it's own method or class. Below are some of the
          # additional values of interest:
          # - get authentication notes / public notes when not found on portfolio
          # - get coverage when not found on availability data or portfolio
          # - get policy?
          # - are all of these relevant all the time? if some of this information is only relevant on show page then our
          # service needs a clean way of knowing when to make these potential additional requests
          Inventory::Electronic.new(mms_id, raw_availability_data, { portfolio: portfolio })
        else
          # when we're here we're dealing with a bib that doesn't have real time availability data (e.g. a collection)
          raise Error, "Type: '#{type}' not found"
        end
      end

      private

      # Dig for inventory data ("holdings") from Alma::AvailabilityResponse
      # @param [String] mms_id
      # @param [Alma::AvailabilityResponse] availability_data that Alma::Bib.get_availability call returns
      # @return [Array<Hash>]
      def inventory_data(mms_id, availability_data)
        availability_data.availability.dig(mms_id, :holdings)
      end

      # Create Inventory classes using inventory data
      # @param [String] mms_id
      # @param [Array<Hash>] inventory_data
      # @return [Array<Inventory::Base>]
      def inventory(mms_id, inventory_data)
        inventory_data.map do |data|
          create(data['inventory_type'], mms_id, data)
        end
      end

      # Retrieve item data for physical inventory
      # @param [String] mms_id
      # @param [String] holding_id
      # @param [Hash] options additional parameters to pass to the request (e.g. limit, offset)
      # @note should we return the entire Alma::BibItemSet instead?
      # @return [Array<Alma::BibItem>] array of items
      def find_items(mms_id, holding_id, **options)
        default_options = { holding_id: holding_id, expand: 'due_date,due_date_policy' }
        Alma::BibItem.find(mms_id, default_options.merge(options)).items
      end

      # Retrieve portfolio data for electronic inventory
      # @param [String, Nil] portfolio_id
      # @param [String] collection_id
      # @param [String, Nil] service_id
      # @return [Hash]
      def find_portfolio(portfolio_id, collection_id = nil, service_id = nil)
        Alma::Electronic.get(collection_id: collection_id,
                             service_id: service_id,
                             portfolio_id: portfolio_id)&.data || {}
      end

      # Retrieve collection data for electronic inventory
      # @param [String] collection_id
      # @return [Hash]
      def find_collection(collection_id)
        Alma::Electronic.get(collection_id: collection_id)&.data || {}
      end

      # Retrieve service data for electronic inventory
      # @param [String] collection_id
      # @param [String] service_id
      # @return [Hash]
      def find_service(collection_id, service_id)
        Alma::Electronic.get(collection_id: collection_id, service_id: service_id)&.data || {}
      end
    end
  end
end
