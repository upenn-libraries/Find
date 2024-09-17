# frozen_string_literal: true

module Inventory
  # Adds necessary functionality to determine item checkout status for rendering circulation options
  class Item
    extend Item::Finders
    include Item::Export
    include Item::Status

    attr_reader :bib_item

    # Delegate specific methods to Alma::BibItem because we override some of the methods provided.
    delegate :item_data, :holding_data, :in_place?, :in_temp_location?, :description, :physical_material_type,
             :public_note, :call_number, :circulation_policy, to: :bib_item

    # @param [Alma::BibItem] bib_item
    def initialize(bib_item)
      @bib_item = bib_item
    end

    # Return item identifier (pid in Alma parlance)
    # @return [String]
    def id
      item_data['pid']
    end

    # @return [String]
    def holding_id
      holding_data['holding_id']
    end

    # Location object containing location details and helper methods.
    # @see #create_location
    # @return [Inventory::Location]
    def location
      @location ||= create_location
    end

    # Get available requesting options
    # @param user [User, nil]
    # @return [Array<Symbol>]
    def request_options(user: nil)
      RequestOptions.new(item: self, user: user).all
    end

    # @return [String]
    def user_due_date_policy
      item_data['due_date_policy']
    end

    # @return [Hash]
    def bib_data
      bib_item.item.fetch('bib_data', {})
    end

    # @return [String]
    def volume
      item_data['enumeration_a']
    end

    # @return [String]
    def issue
      item_data['enumeration_b']
    end

    # Determine the reason why this item is non-circulating based on item policy and location attributes
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
      if (raw_policy == NOT_LOANABLE_POLICY_CODE) && restricted_circ_type.blank?
        I18n.t('requests.form.options.restricted_access')
      elsif on_reserve? then I18n.t('requests.form.options.reserves.label')
      elsif at_reference? then I18n.t('requests.form.options.reference.label')
      elsif in_house_use_only? then I18n.t('requests.form.options.in_house.label')
      elsif !checkoutable? then I18n.t('requests.form.options.unavailable.label')
      else
        raw_policy_for_display raw_policy: raw_policy
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
        # Fake items have no item data, are special collections and therefore can be safely labeled as restricted circ
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

    # Turn "End of Term" and "End of Year" into "Return by End of Year" so this due date policy makes sense in
    # our select option display context.
    # @param [String, nil] raw_policy
    # @return [String]
    def raw_policy_for_display(raw_policy:)
      return nil if raw_policy.blank?

      raw_policy.starts_with?('End of') ? "Return by #{raw_policy}" : raw_policy
    end
  end
end
