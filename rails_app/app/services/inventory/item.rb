# frozen_string_literal: true

module Inventory
  # Adds necessary functionality to determine item checkout status for rendering circulation options
  class Item
    extend Item::Finders
    include Item::Export

    IN_HOUSE_POLICY_CODE = 'InHouseView'
    NOT_LOANABLE_POLICY = 'Not loanable'
    UNSCANNABLE_MATERIAL_TYPES = %w[RECORD DVD CDROM BLURAY BLURAYDVD LP FLOPPY_DISK DAT GLOBE AUDIOCASSETTE
                                    VIDEOCASSETTE HEAD LRDSC CALC KEYS RECORD LPTOP EQUIP OTHER AUDIOVM].freeze

    attr_reader :bib_item

    # delegate to alma bib item
    delegate_missing_to :@bib_item

    # @param [Alma::BibItem] bib_item
    def initialize(bib_item)
      @bib_item = bib_item
    end

    # @return [Hash]
    def bib_data
      @bib_item.item.fetch('bib_data', {})
    end

    # Should the user be able to submit a request for this Item?
    # @return [Boolean]
    def checkoutable?
      in_place? && loanable? && !aeon_requestable? && !on_reserve? && !at_reference? && !in_house_use_only?
    end

    # @return [String]
    def user_due_date_policy
      item_data['due_date_policy']
    end

    # This is tailored to the user_id, if provided
    # @return [Boolean]
    def loanable?
      !user_due_date_policy&.include? NOT_LOANABLE_POLICY
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

    # Is the item able to be scanned?
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
      (item_data.dig('policy', 'value') == 'reserve') || (holding_data.dig('temp_policy', 'value') == 'reserve')
    end

    # @return [Boolean]
    def at_reference?
      (item_data.dig('policy', 'value') == 'reference') || (holding_data.dig('temp_policy', 'value') == 'reference')
    end

    # @return [Boolean]
    def at_archives?
      (library == Constants::ARCHIVES_LIBRARY) || (holding_data.dig('library', 'value') == Constants::ARCHIVES_LIBRARY)
    end

    # @return [Boolean]
    def in_house_use_only?
      item_data.dig('policy', 'value') == IN_HOUSE_POLICY_CODE ||
        holding_data.dig('temp_policy', 'value') == IN_HOUSE_POLICY_CODE
    end

    # @return [Boolean]
    def unavailable?
      !checkoutable? && !aeon_requestable?
    end

    # @return [String]
    def temp_aware_location_display
      if in_temp_location?
        return "(temp) #{holding_data.dig('temp_library', 'value')} - #{holding_data.dig('temp_location', 'value')}"
      end

      "#{holding_library_name} - #{holding_location_name}"
    end

    # @return [String]
    def temp_aware_call_number
      temp_call_num = holding_data['temp_call_number']
      return temp_call_num if temp_call_num.present?

      holding_data['permanent_call_number']
    end

    # @return [String]
    def volume
      item_data['enumeration_a']
    end

    # @return [String]
    def issue
      item_data['enumeration_b']
    end

    # @return [String]
    def aeon_sublocation
      Settings.locations.aeon_sublocation_map[location]
    end

    # @return [String]
    def aeon_site
      Settings.locations.aeon_location_map[library]
    end

    # Return an array of fulfillment options for a given item and ils_group
    # @param ils_group [String] the ILS group code
    # @return [Array<Symbol>]
    def fulfillment_options(ils_group:)
      return [:aeon] if aeon_requestable?
      return [:archives] if at_archives?

      options = pickup_options(ils_group: ils_group)

      return options if ils_group == User::COURTESY_BORROWER_GROUP

      options << Fulfillment::Request::Options::OFFICE if ils_group == User::FACULTY_EXPRESS_GROUP
      options << Fulfillment::Request::Options::MAIL
      options << Fulfillment::Request::Options::ELECTRONIC if scannable?
      options
    end

    # Return pickup options available for this item based on the group
    # @param ils_group [String] the ILS group code
    # @return [Array<Symbol>]
    def pickup_options(ils_group:)
      return [Fulfillment::Request::Options::PICKUP] if checkoutable?
      return [Fulfillment::Request::Options::ILL_PICKUP] if ils_group != User::COURTESY_BORROWER_GROUP

      []
    end

    # Array of arrays. In each sub-array, the first value is the display value and the
    # second value is the submitted value for backend processing. Intended for use with Rails select form element
    # helpers.
    # @return [Array]
    def select_label
      if item_data.present?
        [[description, physical_material_type['desc'], public_note, library_name]
          .compact_blank.join(' - '), item_data['pid']]
      else
        [[holding_data['call_number'], 'Restricted Access'].compact_blank.join(' - '), 'no-item']
      end
    end
  end
end
