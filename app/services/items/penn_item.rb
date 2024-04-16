# frozen_string_literal: true

module Items
  # TODO: fill this out with Franklin PennItem stuff
  # adds necessary functionality to determine item checkout status for rendering circulation options
  class PennItem < Alma::BibItem
    IN_HOUSE_POLICY_CODE = 'InHouseView'

    # @return [TrueClass, FalseClass]
    def checkoutable?
      in_place? &&
        loanable? &&
        !aeon_requestable? &&
        !on_reserve? &&
        !at_reference? &&
        !in_house_use_only?
    end

    # @return [String]
    def pid
      item_data['pid']
    end

    # @return [String]
    def user_due_date_policy
      item_data['due_date_policy']
    end

    # This is tailored to the user_id, if provided
    # @return [TrueClass, FalseClass]
    def loanable?
      !user_due_date_policy&.include? 'Not loanable'
    end

    # @return [TrueClass, FalseClass]
    def aeon_requestable?
      location = if item_data.dig('location', 'value')
                   item_data['location']['value']
                 else
                   holding_data['location']['value']
                 end
      Mappings.aeon_locations.include? location
    end

    # @return [TrueClass, FalseClass]
    def on_reserve?
      item_data.dig('policy', 'value') == 'reserve' ||
        holding_data.dig('temp_policy', 'value') == 'reserve'
    end

    # @return [TrueClass, FalseClass]
    def at_reference?
      item_data.dig('policy', 'value') == 'reference' ||
        holding_data.dig('temp_policy', 'value') == 'reference'
    end

    # @return [TrueClass, FalseClass]
    def in_house_use_only?
      item_data.dig('policy', 'value') == IN_HOUSE_POLICY_CODE ||
        holding_data.dig('temp_policy', 'value') == IN_HOUSE_POLICY_CODE
    end

    # Array of arrays. In each sub-array, the first value is the display value and the
    # second value is the submitted value for backend processing.
    # @return [Array]
    def select_label
      [[description, physical_material_type['desc'], public_note, library_name]
        .compact_blank.join(' - '), item_data['pid']]
    end
  end
end
