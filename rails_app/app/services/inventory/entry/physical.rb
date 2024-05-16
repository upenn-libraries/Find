# frozen_string_literal: true

module Inventory
  class Entry
    # Physical holding class
    class Physical < Inventory::Entry
      # @return [String, nil]
      def status
        data[:availability]
      end

      # Not all "Available" things are actually available - check policy and other attributes for more fidelity in our
      # messaging.
      # @return [Symbol]
      def refined_status
        @refined_status ||= begin
          if first_item.offsite?
            :offsite
          elsif first_item.aeon_requestable?
            :appointment
          elsif first_item.in_house_use_only?
            :in_house
          elsif first_item.checkoutable?
            :circulates
          else
            status.to_sym
          end
        end
      end

      # User-friendly display value for inventory entry status
      # @return [String, nil]
      def human_readable_status
        case status
        when Constants::AVAILABLE then available_status_label
        when Constants::CHECK_HOLDINGS then I18n.t('alma.availability.check_holdings.physical.label')
        when Constants::UNAVAILABLE then I18n.t('alma.availability.unavailable.physical.label')
        else
          status&.capitalize
        end
      end

      # User-friendly display value for inventory entry status description - a more detailed description of
      # what the status indicates
      # @return [String, nil]
      def human_readable_status_description
        case status
        when Constants::AVAILABLE then available_status_description
        when Constants::CHECK_HOLDINGS then I18n.t('alma.availability.check_holdings.physical.description')
        when Constants::UNAVAILABLE then I18n.t('alma.availability.unavailable.physical.description')
        else
          nil
        end
      end

      def available_status_label
        case refined_status
        when :offsite then I18n.t('alma.availability.available.physical.offsite.label')
        when :appointment then I18n.t('alma.availability.available.physical.appointment.label')
        when :in_house then I18n.t('alma.availability.available.physical.in_house.label')
        else
          I18n.t('alma.availability.available.physical.circulates.label')
        end
      end

      def available_status_description
        case refined_status
        when :offsite then I18n.t('alma.availability.available.physical.offsite.description')
        when :appointment then I18n.t('alma.availability.available.physical.appointment.description')
        when :in_house then I18n.t('alma.availability.available.physical.in_house.description')
        else
          I18n.t('alma.availability.available.physical.circulates.description')
        end
      end

      # @return [String, nil]
      def policy
        return unless first_item

        first_item.item_data.dig('policy', 'desc')
      end

      # @return [String, nil]
      def description
        data[:call_number]
      end

      # @return [String, nil]
      def format
        return unless first_item

        first_item.item_data.dig('physical_material_type', 'desc')
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
      def location
        location_code = data[:location_code]
        return unless location_code

        location_override || Mappings.locations[location_code.to_sym][:display]
      end

      # Number of items for this physical holding.
      #
      # @return [String, nil]
      def count
        data[:total_items]
      end

      def physical?
        true
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

      def first_item(**options)
        @first_item ||= retrieve_first_item(mms_id, id)
      end

      def retrieve_first_item(mms_id, holding_id)
        items = Inventory::Service::Physical.items(mms_id: mms_id, holding_id: holding_id)
        return false if items.empty?

        items.first
      end

      # Inventory may have an overridden location that doesn't reflect the location values in the availability data. We
      # utilize the PennMARC location overrides mapper to return such locations.
      # @return [String, nil]
      def location_override
        location_code = data[:location_code]
        call_number = data[:call_number]

        return unless location_code && call_number

        override = Mappings.location_overrides.find do |_key, value|
          value[:location_code] == location_code && call_number.match?(value[:call_num_pattern])
        end

        override&.last&.dig(:specific_location)
      end
    end
  end
end
