# frozen_string_literal: true

module Inventory
  # Encapsulates fulfillment-oriented decisions for a given {Inventory::Location}.
  # Answers questions about how a location behaves in request/fulfillment flows —
  # what type of access it requires, what status labels apply, and how to route
  # to external systems like Aeon.
  class LocationPolicy
    # Top-level keys mirror Constants::AVAILABLE_KEY / CHECK_HOLDINGS_KEY / UNAVAILABLE_KEY
    # so that renaming a status key in one place updates both consumers.
    STATUS_KEYS = {
      Constants::AVAILABLE_KEY => {
        aeon_offsite: :offsite_appointment,
        aeon_onsite: :appointment,
        offsite: :offsite,
        restricted_onsite: :unrequestable,
        general: :circulates
      },
      Constants::CHECK_HOLDINGS_KEY => {
        aeon_offsite: :appointment,
        aeon_onsite: :appointment,
        offsite: :mixed_availability,
        restricted_onsite: :mixed_availability,
        general: :mixed_availability
      },
      Constants::UNAVAILABLE_KEY => {
        aeon_offsite: :appointment,
        aeon_onsite: :appointment
      }
    }.freeze

    attr_reader :location

    # @param location [Inventory::Location]
    # @param aeon_locations [Array<Symbol>] collection of location codes that route through Aeon
    def initialize(location, aeon_locations: Mappings.aeon_locations)
      @location = location
      @aeon_locations = aeon_locations
    end

    # Return location's Aeon sublocation code.
    #
    # @return [String]
    def aeon_sublocation
      Settings.locations.aeon_sublocation_map[location.code]
    end

    # Return location's Aeon site code.
    #
    # @return [String]
    def aeon_site
      Settings.locations.aeon_location_map[location.library_code]
    end

    # Returns true if material is in resource sharing library.
    #
    # @return [Boolean]
    def resource_sharing_library?
      location.library_code == Settings.fulfillment.restricted_libraries.res_share
    end

    # Return true if the location requires the user to log in before requesting.
    # Locations like Aeon, Archives, and HSP bypass the login gate because their
    # request flows are handled outside the standard Alma fulfillment form.
    #
    # @return [Boolean]
    def requires_authentication?
      !profile.in?(%i[aeon_offsite aeon_onsite restricted_onsite])
    end

    # Return the status key to use for available items at this location.
    # Priority ordering: offsite special collections > special collections >
    # offsite general > on-site restricted > general circulation.
    #
    # @return [Symbol]
    def available_status_key
      STATUS_KEYS.dig(:available, profile)
    end

    # Return the status key to use for check_holdings items at this location.
    #
    # @return [Symbol]
    def check_holdings_status_key
      STATUS_KEYS.dig(:check_holdings, profile)
    end

    # Return the status key to use for unavailable items at this location.
    #
    # @return [Symbol, nil]
    def unavailable_status_key
      STATUS_KEYS.dig(:unavailable, profile)
    end

    # Return true if material is requestable via Aeon.
    #
    # @return [Boolean]
    def aeon?
      profile.in?(%i[aeon_offsite aeon_onsite])
    end

    # Return true if material is at the Archives. Archives material cannot be
    # requested and require an in-person visit.
    #
    # @return [Boolean]
    def archives?
      location.library_code == Settings.fulfillment.restricted_libraries.archives
    end

    # Return true if material is at the Historical Society of Pennsylvania (HSP).
    # HSP items cannot be requested and require an in-person visit to their facilities.
    #
    # @return [Boolean]
    def hsp?
      location.library_code == Settings.fulfillment.restricted_libraries.hsp
    end

    # Return true if material is in LIBRA. LIBRA materials cannot be "picked up
    # at the library" — they must be requested.
    #
    # @return [Boolean]
    def libra?
      location.library_code == Settings.fulfillment.restricted_libraries.libra
    end

    private

    # Returns a profile symbol that characterizes this location's fulfillment
    # behavior. Used internally to avoid repeating boolean checks across
    # multiple public methods.
    #
    # @return [Symbol]
    def profile
      if aeon_library?
        libra? ? :aeon_offsite : :aeon_onsite
      elsif libra?
        :offsite
      elsif archives? || hsp?
        :restricted_onsite
      else
        :general
      end
    end

    # @return [Boolean]
    def aeon_library?
      @aeon_locations.include?(location.code)
    end
  end
end
