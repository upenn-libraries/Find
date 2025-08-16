# frozen_string_literal: true

# Provides consistent interface to access necessary mappings
class Mappings
  class << self
    # @return [Hash]
    def locations
      @locations ||= PennMARC::Mappers.location
    end

    # @return [Hash]
    def location_overrides
      @location_overrides ||= PennMARC::Mappers.location_overrides
    end

    # Return all locations marked as aeon in the locations file
    # @return [Array<String>]
    def aeon_locations
      @aeon_locations = locations.filter_map { |code, details| details[:aeon] ? code.to_s : nil }
    end

    # @return [Array]
    def offsite_locations
      Settings.locations[:offsite]
    end

    # @return [Array]
    def unavailable_locations
      Settings.locations[:unavailable]
    end

    # @return [Hash]
    delegate :electronic_scoring, to: :Settings
  end
end
