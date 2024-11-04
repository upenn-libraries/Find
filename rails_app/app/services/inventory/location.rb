# frozen_string_literal: true

module Inventory
  # Representing an Alma location. Alma locations are always within a library. This class centralizes information we
  # often extrapolate about a location in Alma.
  class Location
    ARCHIVES = 'UnivArcLib'
    HSP = 'HSPLib'
    LIBRA = 'Libra'

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
      library_code == HSP
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
      library_code == ARCHIVES
    end

    # Return true if material is in LIBRA. LIBRA materials cannot be "picked up at the library" they must be requested.
    # @return [Boolean]
    def libra?
      library_code == LIBRA
    end

    # Return location's Aeon sublocation code from PennMARC locations config file
    #
    # @return [String]
    def aeon_sublocation
      PennMARC::Mappers.location[code][:aeon]
    end

    # Return location's Aeon site code.
    #
    # @return [String]
    def aeon_site
      Settings.locations.aeon_location_map[library_code]
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
