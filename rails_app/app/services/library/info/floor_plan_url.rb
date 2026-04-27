# frozen_string_literal: true

module Library
  module Info
    # Handles logic for connecting catalog items to their floor plans on the library website.
    class FloorPlanUrl
      attr_reader :library_info, :call_number, :location_code

      # @param library_info [Library::Info::Request]
      # @param call_number [String, nil]
      # @param location_code [String, nil]
      def initialize(library_info:, call_number:, location_code: nil)
        @library_info = library_info
        @call_number = call_number
        @location_code = location_code
      end

      delegate :floor_plans, :floors_data, to: :library_info

      # Returns the url for an item's floor's floor plan, or building if no specific floor can be
      # found, or nil if a floor plan could not be connected.
      #
      # @return [String, nil]
      def get
        return unless floor_plans

        floor_url_by_location_code || floor_url_by_call_number || landing_page_url
      end

      private

      # Returns the floor plan landing page URL for the library's building.
      #
      # @return [String, nil]
      def landing_page_url
        floor_plans&.dig('building', 'url')
      end

      # Returns the floor plan "floor" URL if a floor has a matching Alma location code.
      #
      # @return [String, nil]
      def floor_url_by_location_code
        return unless location_code

        match = location_codes_by_floor.find { |_url, codes| codes&.include?(location_code) }

        match&.first
      end

      # Creates a hash mapping each floor's url to its Alma location codes.
      #
      # @return [Hash{String => Array<String>}]
      def location_codes_by_floor
        floors_data.to_h do |floor|
          [floor['url'], floor['alma_location_codes']]
        end
      end

      # Returns the floor plan "floor" URL if the call number falls within a floor's call number ranges.
      #
      # @return [String, nil]
      def floor_url_by_call_number
        return unless call_number

        match = call_number_ranges_by_floor.find do |_url, ranges|
          ranges.any? { |range| call_number_in_range?(range) }
        end

        match&.first
      end

      # Checks whether the call number falls within a classification code range.
      # If there is only a "start" value checks whether the call number starts with that.
      #
      # @param range [Hash] hash of 'start' and (optional) 'end' classification code values
      # @return [Boolean]
      def call_number_in_range?(range)
        if range['end'].blank?
          call_number.start_with?(range['start'])
        else
          Range.new(range['start'], range['end']).cover?(call_number)
        end
      end

      # Creates a hash mapping each floor's URL to its classification code ranges.
      #
      # @return [Hash{String => Array<Hash>}]
      def call_number_ranges_by_floor
        floors_data.to_h do |floor|
          [floor['url'], floor['loc_classification_ranges']]
        end
      end
    end
  end
end
