# frozen_string_literal: true

module Inventory
  # Supplement Alma::BibItem with additional functionality
  class Item
    extend Item::Finders
    include Item::Export

    attr_reader :bib_item

    # Delegate specific methods to Alma::BibItem because we override some of the methods provided.
    delegate :item_data, :holding_data, :in_place?, :in_temp_location?, :description, :physical_material_type,
             :public_note, :call_number, to: :bib_item

    # @param [Alma::BibItem] bib_item
    def initialize(bib_item)
      @bib_item = bib_item
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
    # @return [String]
    def id
      item_data['pid']
    end

    # @return [String]
    def holding_id
      holding_data['holding_id']
    end

    # Returns true if record is marked as a boundwith.
    # @return [Boolean]
    def boundwith?
      @bib_item.item.fetch('boundwith', false)
    end

    # @return [String]
    def user_due_date_policy
      item_data['due_date_policy']
    end

    # Turn "End of Term" and "End of Year" into "Return by End of Year" so this due date policy makes sense in
    # our select option display context.
    # @return [String, nil]
    def humanized_user_policy
      user_due_date_policy&.starts_with?('End of') ? "Return by #{user_due_date_policy}" : user_due_date_policy
    end

    # Array of arrays. In each sub-array, the first value is the display value and the
    # second value is the submitted value for backend processing. Intended for use with Rails select form element
    # helpers.
    # @return [Array]
    def select_label
      if item_data.present?
        [[description, physical_material_type['desc'], public_note, location.library_name, humanized_user_policy]
          .compact_blank.join(' - '), item_data['pid']]
      else
        [[call_number, 'Restricted Access'].compact_blank.join(' - '), 'no-item']
      end
    end

    # @return [String]
    def item_policy
      item_data.dig('policy', 'value')
    end

    # Policy value that takes into account the holding being in a temp location
    # @return [String]
    def policy
      in_temp_location? ? holding_data.dig('temp_policy', 'value') : item_data.dig('policy', 'value')
    end

    # @return [String]
    def volume
      item_data['enumeration_a']
    end

    # @return [String]
    def issue
      item_data['enumeration_b']
    end

    # @return [String, nil]
    def material_type_value
      physical_material_type['value']
    end

    # Return an array of available request options as reported by Alma
    # @return [Array]
    def request_options_list(user_id: nil)
      @request_options_list ||= request_options(user_id: user_id)&.filter_map do |option|
        option.dig 'type', 'value'
      end || []
    end

    private

    # Get an ItemRequestOptions object from the Alma gem, raising an exception if theres a problem getting an mms id
    # @param user_id [nil, String] optionally send a user_id for more personalized results
    # @return [Alma::ItemRequestOptions, nil]
    def request_options(user_id: nil)
      mms_id = bib_item['bib_data']['mms_id']
      raise StandardError, "Problem getting Request Options via MMS ID for Item with PID #{id}." if mms_id.blank?

      options = {}
      options[:user_id] = user_id if user_id.present?
      Alma::ItemRequestOptions.get mms_id, holding_id, id, options
    end

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
