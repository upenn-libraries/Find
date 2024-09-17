# frozen_string_literal: true

module Inventory
  class Item
    # Instance that represent the status of an Item for informational or fulfillment contexts.
    module Status
      NON_CIRC_POLICY_CODE = 'Non-circ'
      IN_HOUSE_POLICY_CODE = 'InHouseView'
      NOT_LOANABLE_POLICY_CODE = 'Not loanable'
      RESERVES_POLICY_CODE = 'reserve'
      REFERENCE_POLICY_CODE = 'reference'
      UNSCANNABLE_MATERIAL_TYPES = %w[RECORD DVD CDROM BLURAY BLURAYDVD LP FLOPPY_DISK DAT GLOBE AUDIOCASSETTE
                                      VIDEOCASSETTE HEAD LRDSC CALC KEYS RECORD LPTOP EQUIP OTHER AUDIOVM].freeze

      # Returns true if record is marked as a boundwith.
      # @return [Boolean]
      def boundwith?
        bib_item.item.fetch('boundwith', false)
      end

      # Should the user be able to submit a request for this Item? Alma may consider something loanable but we do not
      # to provide means for users to check them out.
      # @return [Boolean]
      def checkoutable?
        in_place? && loanable? && !location.aeon? && !on_reserve? && !at_reference? && !in_house_use_only?
      end

      # This is tailored to the user_id, if provided. Without a user_id sent in the API request for the item,
      # `user_due_date_policy` will not appear in the response.
      # @return [Boolean]
      def loanable?
        !user_due_date_policy&.include? NOT_LOANABLE_POLICY_CODE
      end

      # Is the item able to be scanned?
      # - HSP items won't be scanned
      # - Aeon items won't be scanned (via resource sharing)
      # - Items with a format in UNSCANNABLE_MATERIAL_TYPES can't be scanned
      # @return [Boolean]
      def scannable?
        return false if location.hsp?

        location.aeon? || !item_data.dig('physical_material_type', 'value').in?(UNSCANNABLE_MATERIAL_TYPES)
      end

      # Does the item have a non-circulation policy value?
      # Penn uses "Non-circ" in Alma so we cannot delegate to the Alma::BibItem method of the same name
      # @return [Boolean]
      def non_circulating?
        circulation_policy.include?(NON_CIRC_POLICY_CODE)
      end

      # @return [Boolean]
      def on_reserve?
        (item_data.dig('policy', 'value') == RESERVES_POLICY_CODE) ||
          (holding_data.dig('temp_policy', 'value') == RESERVES_POLICY_CODE)
      end

      # @return [Boolean]
      def at_reference?
        (item_data.dig('policy', 'value') == REFERENCE_POLICY_CODE) ||
          (holding_data.dig('temp_policy', 'value') == REFERENCE_POLICY_CODE)
      end

      # @return [Boolean]
      def in_house_use_only?
        item_data.dig('policy', 'value') == IN_HOUSE_POLICY_CODE ||
          holding_data.dig('temp_policy', 'value') == IN_HOUSE_POLICY_CODE
      end
    end
  end
end
