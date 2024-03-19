# frozen_string_literal: true

module Inventory
  # Provides consistent interface to access necessary mappings for our Inventory Service
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

      # @return [Array]
      def aeon_locations
        @aeon_locations ||= load_file('config/translation_maps/aeon_locations.yml')
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
      def electronic_scoring
        Settings.electronic_scoring
      end

      private

      # @param path [String] path to mapping file relative to root directory
      # @return [Hash, Array]
      def load_file(path)
        YAML.safe_load(File.read(Rails.root.join(path)))
      end
    end
  end
end
