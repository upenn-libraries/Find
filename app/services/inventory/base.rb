# frozen_string_literal: true

module Inventory
  # Base class that all Inventory classes inherit from
  class Base
    attr_reader :status, :policy, :description, :format, :id, :href, :raw_availability_data, :mms_id

    # @param[String] mms_id
    # @param[Hash] raw_availability_data hash containing inventory data retrieved from Alma real time availability API
    # See Alma::AvailabilityResponse for mapping of values into the raw_availability_data hash
    def initialize(mms_id, raw_availability_data)
      @mms_id = mms_id
      @raw_availability_data = raw_availability_data
    end

    # @return [String, nil]
    def count
      raw_availability_data['total_items']
    end

    # @return [String, nil]
    def location
      location_code = raw_availability_data['location_code']
      return unless location_code

      location_override || PennMARC::Mappers.location[location_code.to_sym][:display]
    end

    # @return [String, nil]
    def type
      raw_availability_data['inventory_type']
    end

    # @return [Hash]
    def to_h
      {
        status: status, policy: policy, description: description, format: format, count: count,
        location: location, id: id, href: href, type: type
      }
    end

    private

    # Inventory may have an overridden location that doesn't reflect the location values in the availability data. We
    # utilize the PennMARC location overrides mapper to return such locations.
    # @return [String, nil]
    def location_override
      location_code = raw_availability_data['location_code']
      call_number = raw_availability_data['call_number']

      return unless location_code && call_number

      override = PennMARC::Mappers.location_overrides.find do |_key, value|
        value[:location_code] == location_code && call_number.match?(value[:call_num_pattern])
      end

      override&.dig(override.key, :specific_location)
    end
  end
end
