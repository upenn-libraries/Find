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

    # Delegate specific methods to Alma::BibItem because we override some of the methods provided.
    delegate :item_data, :holding_data, :in_place?, :in_temp_location?, :description, :physical_material_type,
             :public_note, :call_number, to: :bib_item

    # @param [Alma::BibItem] bib_item
    def initialize(bib_item)
      @bib_item = bib_item
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

    # Location object containing location details and helper methods.
    # @see #create_location
    # @return [Inventory::Location]
    def location
      @location ||= create_location
    end

    # Is the item able to be scanned?
    # @return [Boolean]
    def scannable?
      return false if location.hsp?

      location.aeon? || !item_data.dig('physical_material_type', 'value').in?(UNSCANNABLE_MATERIAL_TYPES)
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

    # @return [Boolean]
    def unavailable?
      !checkoutable? && !location.aeon?
    end

    # @return [String]
    def volume
      item_data['enumeration_a']
    end

    # @return [String]
    def issue
      item_data['enumeration_b']
    end

    # Return an array of fulfillment options for a given item and user. Certain requesting options (ie Aeon) are
    # available to non-logged in users.
    #
    # @param user [User, nil] the user object
    # @return [Array<Symbol>]
    def fulfillment_options(user: nil)
      return [:aeon] if location.aeon?
      return [:archives] if location.archives?
      return [:hsp] if location.hsp?
      return [] if user.nil? # If user is not logged in, no more requesting options can be exposed.

      user.courtesy_borrower? ? courtesy_borrower_options : penn_borrower_options(user)
    end

    # Fulfillment options available for Penn users.
    # @param user [User]
    # @return [Array<Symbol>]
    def penn_borrower_options(user)
      options = [Fulfillment::Request::Options::MAIL]
      options << (checkoutable? ? Fulfillment::Request::Options::PICKUP : Fulfillment::Request::Options::ILL_PICKUP)
      options << Fulfillment::Request::Options::OFFICE if user.faculty_express?
      options << Fulfillment::Request::Options::ELECTRONIC if scannable?
      options
    end

    # Fulfillment options available for courtesy borrowers. Courtesy borrowers can't make inter-library loan requests.
    # @return [Array<Symbol>]
    def courtesy_borrower_options
      checkoutable? ? [Fulfillment::Request::Options::PICKUP] : []
    end

    # Array of arrays. In each sub-array, the first value is the display value and the
    # second value is the submitted value for backend processing. Intended for use with Rails select form element
    # helpers.
    # @return [Array]
    def select_label
      if item_data.present?
        [[description, physical_material_type['desc'], public_note, location.library_name]
          .compact_blank.join(' - '), item_data['pid']]
      else
        [[call_number, 'Restricted Access'].compact_blank.join(' - '), 'no-item']
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
