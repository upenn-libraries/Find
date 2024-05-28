# frozen_string_literal: true

module Inventory
  # Extend the Inventory::Service to include extra bib item methods
  class Service
    # Adds necessary functionality to determine item checkout status for rendering circulation options
    class Item < Alma::BibItem
      IN_HOUSE_POLICY_CODE = 'InHouseView'
      UNSCANNABLE_MATERIAL_TYPES = %w[
        RECORD DVD CDROM BLURAY BLURAYDVD LP FLOPPY_DISK DAT GLOBE
        AUDIOCASSETTE VIDEOCASSETTE HEAD LRDSC CALC KEYS RECORD
        LPTOP EQUIP OTHER AUDIOVM
      ].freeze

      # @return [Boolean]
      def checkoutable?
        in_place? &&
          loanable? &&
          !aeon_requestable? &&
          !on_reserve? &&
          !at_reference? &&
          !in_house_use_only?
      end

      # @return [Hash]
      def bib_data
        @item.fetch('bib_data', {})
      end

      # @return [String]
      def user_due_date_policy
        item_data['due_date_policy']
      end

      # This is tailored to the user_id, if provided
      # @return [Boolean]
      def loanable?
        !user_due_date_policy&.include? 'Not loanable'
      end

      # @return [Boolean]
      def aeon_requestable?
        location = if item_data.dig('location', 'value')
                     item_data['location']['value']
                   else
                     holding_data['location']['value']
                   end
        Mappings.aeon_locations.include? location
      end

      # Is the item able to be Scan&Deliver'd?
      # @return [Boolean]
      def scannable?
        return false if at_hsp?

        aeon_requestable? || !item_data.dig('physical_material_type', 'value').in?(UNSCANNABLE_MATERIAL_TYPES)
      end

      # Is the item a Historical Society of Pennsylvania record? If so, it cannot be requested.
      # @return [Boolean]
      def at_hsp?
        library == Constants::HSP_LIBRARY
      end

      # @return [Boolean]
      def on_reserve?
        item_data.dig('policy', 'value') == 'reserve' ||
          holding_data.dig('temp_policy', 'value') == 'reserve'
      end

      # @return [Boolean]
      def at_reference?
        item_data.dig('policy', 'value') == 'reference' ||
          holding_data.dig('temp_policy', 'value') == 'reference'
      end

      # @return [Boolean]
      def at_archives?
        library == Constants::ARCHIVES_LIBRARY ||
          holding_data.dig('library', 'value') == Constants::ARCHIVES_LIBRARY
      end

      # @return [Boolean]
      def in_house_use_only?
        item_data.dig('policy', 'value') == IN_HOUSE_POLICY_CODE ||
          holding_data.dig('temp_policy', 'value') == IN_HOUSE_POLICY_CODE
      end

      # Array of arrays. In each sub-array, the first value is the display value and the
      # second value is the submitted value for backend processing.
      # @return [Array]
      def select_label
        if item_data.present?
          [[description, physical_material_type['desc'], public_note, library_name]
            .compact_blank.join(' - '), item_data['pid']]
        else
          [[holding_data['call_number'], 'Restricted Access'].compact_blank.join(' - '), 'no-item']
        end
      end

      # Return an array of fulfillment options for a given item and ils_group
      # @param ils_group [String] the ILS group code
      # @return [Array<Symbol>]
      def fulfillment_options(ils_group:)
        return [:aeon] if aeon_requestable?
        return [:archives] if at_archives?

        options = []
        if checkoutable?
          options << :pickup
          options << :office if ils_group == User::FACULTY_EXPRESS_GROUP
          options << :mail unless ils_group == User::COURTESY_BORROWER_GROUP
          options << :scan if scannable?
        end
        options
      end
    end
  end
end
