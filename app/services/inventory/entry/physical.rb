# frozen_string_literal: true

module Inventory
  class Entry
    # Physical holding class
    class Physical < Inventory::Entry
      attr_reader :items

      # @param [String] mms_id
      # @param [Hash] data from Alma real time availability request
      # @param [Array<Alma::BibItem>] items array of items from Alma::BibItem request
      def initialize(mms_id, data, items)
        super(mms_id, data)
        @items = items
      end

      # @note possible values seem to be "available", "unavailable", and "check_holdings" when present
      # @return [String, nil]
      def status
        data[:availability]
      end

      # @return [String, nil]
      def policy
        return if items.empty?

        items.first.item_data.dig('policy', 'desc')
      end

      # @return [String, nil]
      def description
        data[:call_number]
      end

      # @return [String, nil]
      def format
        return if items.empty?

        items.first.item_data.dig('physical_material_type', 'desc')
      end

      # @return [String, nil]
      def id
        data[:holding_id]
      end

      # @return [String, nil]
      def href
        return nil if id.blank?

        Rails.application.routes.url_helpers.solr_document_path(mms_id, hld_id: id)
      end
    end
  end
end
