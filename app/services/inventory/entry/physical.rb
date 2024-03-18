# frozen_string_literal: true

module Inventory
  class Entry
    # Physical holding class
    class Physical < Inventory::Entry
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
      def coverage_statement
        data[:holding_info]
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

      # @return [String, nil]
      def count
        data[:total_items]
      end

      # @return [String, nil]
      def location
        location_code = data[:location_code]
        return unless location_code

        location_override || PennMARC::Mappers.location[location_code.to_sym][:display]
      end

      private

      def items
        @items ||= find_items
      end

      def find_items(**options)
        default_options = { holding_id: id, expand: 'due_date,due_date_policy' }
        resp = Alma::BibItem.find(mms_id, default_options.merge(options))
        resp.items || []
      end

      # Inventory may have an overridden location that doesn't reflect the location values in the availability data. We
      # utilize the PennMARC location overrides mapper to return such locations.
      # @return [String, nil]
      def location_override
        location_code = data[:location_code]
        call_number = data[:call_number]

        return unless location_code && call_number

        override = PennMARC::Mappers.location_overrides.find do |_key, value|
          value[:location_code] == location_code && call_number.match?(value[:call_num_pattern])
        end

        override&.last&.dig(:specific_location)
      end
    end
  end
end
