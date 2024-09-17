# frozen_string_literal: true

module Inventory
  # Adds necessary functionality to determine item checkout status for rendering circulation options
  class Item
    extend Item::Finders
    include Item::Export

    NON_CIRC_POLICY_CODE = 'Non-circ'
    IN_HOUSE_POLICY_CODE = 'InHouseView'
    NOT_LOANABLE_POLICY = 'Not loanable'
    UNSCANNABLE_MATERIAL_TYPES = %w[RECORD DVD CDROM BLURAY BLURAYDVD LP FLOPPY_DISK DAT GLOBE AUDIOCASSETTE
                                    VIDEOCASSETTE HEAD LRDSC CALC KEYS RECORD LPTOP EQUIP OTHER AUDIOVM].freeze

    attr_reader :bib_item

    # Delegate specific methods to Alma::BibItem because we override some of the methods provided.
    delegate :item_data, :holding_data, :in_place?, :in_temp_location?, :description, :physical_material_type,
             :public_note, :call_number, :circulation_policy, to: :bib_item

    # @param [Alma::BibItem] bib_item
    def initialize(bib_item)
      @bib_item = bib_item
    end

    # Get available requesting options
    # @param user [User, nil]
    # @return [Array<Symbol>]
    def request_options(user: nil)
      Item::RequestOptions.new(item: self, user: user).all
    end

    # Location object containing location details and helper methods.
    # @see #create_location
    # @return [Inventory::Location]
    def location
      @location ||= create_location
    end

    # @return [Hash]
    def bib_data
      @bib_item.item.fetch('bib_data', {})
    end

    # Return item identifier
    def id
      item_data['pid']
    end

    def holding_id
      holding_data['holding_id']
    end

    # Returns true if record is marked as a boundwith.
    def boundwith?
      @bib_item.item.fetch('boundwith', false)
    end

    # Should the user be able to submit a request for this Item?
    # @return [Boolean]
    def checkoutable?
      in_place? && loanable? && !location.aeon? && !on_reserve? && !at_reference? && !in_house_use_only?
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

    # Is the item able to be scanned?
    # @return [Boolean]
    def scannable?
      return false if location.hsp?

      location.aeon? || !item_data.dig('physical_material_type', 'value').in?(UNSCANNABLE_MATERIAL_TYPES)
    end

    # Penn uses "Non-circ" in Alma
    # @return [Boolean]
    def non_circulating?
      circulation_policy.include?(NON_CIRC_POLICY_CODE)
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
    def in_house_use_only?
      item_data.dig('policy', 'value') == IN_HOUSE_POLICY_CODE ||
        holding_data.dig('temp_policy', 'value') == IN_HOUSE_POLICY_CODE
    end

    # @return [String]
    def volume
      item_data['enumeration_a']
    end

    # @return [String]
    def issue
      item_data['enumeration_b']
    end

    # @return [Symbol, nil]
    def restricted_circ_type
      if location.aeon?
        :aeon
      elsif location.archives? then :archives
      elsif location.hsp? then :hsp
      elsif on_reserve? then :reserves
      elsif at_reference? then :reference
      elsif in_house_use_only? then :in_house
      end
    end

    # Prepare a "due date policy" value for display
    # @param raw_policy [String]
    # @return [String]
    def user_policy_display(raw_policy)
      if (raw_policy == NOT_LOANABLE_POLICY) && restricted_circ_type.blank?
        I18n.t('requests.form.options.restricted_access')
      elsif on_reserve?
        I18n.t('requests.form.options.reserves.label')
      elsif at_reference?
        I18n.t('requests.form.options.reference.label')
      elsif in_house_use_only?
        I18n.t('requests.form.options.in_house.label')
      elsif !checkoutable?
        I18n.t('requests.form.options.none.label')
      else
        case raw_policy
        when 'End of Year'
          'Return by End of Year'
        when 'End of Term'
          'Return by End of Term'
        else
          raw_policy
        end
      end
    end

    # Array of arrays. In each sub-array, the first value is the display value and the
    # second value is the submitted value for backend processing. Intended for use with Rails select form element
    # helpers.
    # @return [Array]
    def select_label
      if item_data.present?
        [[description, user_policy_display(user_due_date_policy), physical_material_type['desc'], public_note,
          location.library_name].compact_blank.join(' - '), item_data['pid']]
      else
        [[call_number, I18n.t('requests.form.options.restricted_access')].compact_blank.join(' - '), 'no-item']
      end
    end

    private

    # Returns location object. If item in a temp location, returns that as the location. If a location is not
    # available in the item_data pulls location information from holding_data.
    # @return [Inventory::Location]
    def create_location
      library = in_temp_location? ? holding_data['temp_library'] : item_data['library'] || holding_data['library']
      location = in_temp_location? ? holding_data['temp_location'] : item_data['location'] || holding_data['location']

      Location.new(library_code: library['value'], library_name: library['desc'],
                   location_code: location['value'], location_name: location['desc'])
    end
  end
end
