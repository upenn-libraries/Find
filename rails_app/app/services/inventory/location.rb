# frozen_string_literal: true

module Inventory
  # Representing an Alma location. Alma locations are always within a library. This class centralizes information we
  # often extrapolate about a location in Alma.
  class Location
    attr_reader :location_code, :library_code, :raw_location_name, :raw_library_name

    def initialize(library_code:, library_name:, location_code:, location_name:)
      @location_code = location_code
      @library_code = library_code
      @raw_location_name = location_name
      @raw_library_name = library_name
    end

    alias code location_code

    # Preferred location name. Most locations have a preferred location name configured in a PennMarc mapper. In some
    # rare cases the preferred location name has been overwritten for a subset of the materials in that location. In
    # these cases the call number is need to provide a more specific location name.
    #
    # @param [String, nil] call_number
    # @param [String, nil] call_number_type
    # @return [String]
    def location_name(call_number: nil, call_number_type: nil)
      return I18n.t('inventory.res_share_location_label') if resource_sharing_library?

      location_name_override(call_number, call_number_type) ||
        Mappings.locations.dig(location_code.to_sym, :display) ||
        raw_location_name
    end
    alias name location_name

    # @return [String]
    def library_name
      raw_library_name
    end

    # Return true if material is at the Historical Society of Pennsylvania (HSP). HSP items cannot be requested and
    # require an in-person visit to their facilities.
    #
    # @return [Boolean]
    def hsp?
      library_code == Settings.fulfillment.restricted_libraries.hsp
    end

    # Return true if material is requestable via Aeon.
    #
    # @return [Boolean]
    def aeon?
      Mappings.aeon_locations.include?(code)
    end

    # Return true if material is at the Archives. Archives material cannot be requested and require an in-person visit.
    #
    # @return [Boolean]
    def archives?
      library_code == Settings.fulfillment.restricted_libraries.archives
    end

    # Return true if material is in LIBRA. LIBRA materials cannot be "picked up at the library" they must be requested.
    # @return [Boolean]
    def libra?
      library_code == Settings.fulfillment.restricted_libraries.libra
    end

    # Return location's Aeon sublocation code.
    #
    # @return [String]
    def aeon_sublocation
      Settings.locations.aeon_sublocation_map[code]
    end

    # Return location's Aeon site code.
    #
    # @return [String]
    def aeon_site
      Settings.locations.aeon_location_map[library_code]
    end

    # Returns true if material is in resource sharing library.
    #
    # @return [Boolean]
    def resource_sharing_library?
      library_code == Settings.fulfillment.restricted_libraries.res_share
    end

    # Return true if the location requires the user to log in before requesting.
    # Locations like Aeon, Archives, and HSP bypass the login gate because their
    # request flows are handled outside the standard Alma fulfillment form.
    #
    # @return [Boolean]
    def requires_authentication?
      !aeon? && !archives? && !hsp?
    end

    # Return the status key to use for available items at this location.
    # Priority ordering: offsite special collections > special collections >
    # offsite general > on-site restricted > general circulation.
    #
    # @return [Symbol]
    def available_status_key
      if aeon? && libra?
        :offsite_appointment
      elsif aeon?
        :appointment
      elsif libra?
        :offsite
      elsif archives? || hsp?
        :unrequestable
      else
        :circulates
      end
    end

    # Return the status key to use for check_holdings items at this location.
    #
    # @return [Symbol]
    def check_holdings_status_key
      aeon? ? :appointment : :mixed_availability
    end

    # Return the status key to use for unavailable items at this location.
    #
    # @return [Symbol, nil]
    def unavailable_status_key
      aeon? ? :appointment : nil
    end

    private

    # Location may have an overridden location name that doesn't reflect the location values in the availability data.
    # We utilize the PennMARC location overrides mapper to return such locations.
    # @param call_number [String, nil]
    # @param call_number_type [String, nil]
    # @return [String, nil]
    def location_name_override(call_number, call_number_type)
      return if call_number.blank? || call_number_type.blank? || location_code.blank?

      override = Mappings.location_overrides.find do |_key, override_data|
        override_matching?(override_data: override_data, location_code: location_code, call_number: call_number,
                           call_num_type: call_number_type)
      end

      override&.last&.dig(:specific_location)
    end

    # Check override_data hash for a matching location name override
    # @param override_data [String]
    # @param location_code [String]
    # @param call_number [String]
    # @param call_num_type [String]
    # @return [Boolean]
    def override_matching?(override_data:, location_code:, call_number:, call_num_type:)
      override_data[:location_code] == location_code &&
        override_data[:call_num_type] == call_num_type &&
        call_number.match?(override_data[:call_num_pattern])
    end
  end
end
