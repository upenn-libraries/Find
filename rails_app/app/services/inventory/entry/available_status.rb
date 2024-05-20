# frozen_string_literal: true

module Inventory
  class Entry
    # Class for clarifying what "available" means as an inventory status. Material at ome Penn locations can only be
    # accesses by request even though Alma reports it as "Available". This class adjusts the terminology used when
    # labeling availability so that it displays appropriate guidance for the holding's location
    class AvailableStatus
      attr_accessor :library, :location

      # @param library_code [String]
      # @param location_code [String]
      def initialize(library_code:, location_code:)
        @library = library_code
        @location = location_code
      end

      # Return a refines available status, because some things Alma reports as available are available only under
      # some restrictions we want to make explicit in our status display. Order of the logic here matters, so that
      # items at LIBRA that require an Aeon Request are properly handled, for example.
      # @return [Symbol]
      def refined
        @refined ||= if aeon_location?
                       :appointment
                     elsif offsite?
                       :offsite
                     elsif archives? || hsp?
                       :unrequestable
                     else
                       :circulates
                     end
      end

      # @return [String]
      def label
        i18n_data(:label)
      end

      # @return [String]
      def description
        i18n_data(:description)
      end

      private

      # @return [String]
      def i18n_data(key)
        scope = %i[alma availability available physical]
        scope << refined
        I18n.t(key, scope: scope)
      end

      # Offsite materials cannot be "picked up at the library"
      # @return [Boolean]
      def offsite?
        library == Constants::LIBRA_LIBRARY
      end

      # Archives material cannot be requested and require an in-person visit
      # @return [Boolean]
      def archives?
        library == Constants::ARCHIVES_LIBRARY
      end

      # HSP (Historical Society of Pennsylvania) material cannot be requested and require an in-person visit
      # @return [Boolean]
      def hsp?
        library == Constants::HSP_LIBRARY
      end

      # This in an Aeon location...must go through Aeon
      # @return [Boolean]
      def aeon_location?
        Mappings.aeon_locations.include?(location)
      end
    end
  end
end
