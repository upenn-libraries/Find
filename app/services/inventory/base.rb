# frozen_string_literal: true

module Inventory
  # Base class that all Inventory classes inherit from
  class Base
    attr_reader :status, :policy, :description, :format, :id, :href, :raw_api_data, :mms_id

    # @param[mms_id]
    # @param[raw_api_data] raw_api_data hash containing inventory data retrieved from Alma real time availability API
    # See Alma::AvailabilityResponse for mapping of values into the raw_api_data hash
    def initialize(mms_id, raw_api_data)
      @mms_id = mms_id
      @raw_api_data = raw_api_data
    end

    # @return [String, nil]
    def count
      raw_api_data['total_items']
    end

    # @return [String, nil]
    def location
      raw_api_data['library']
    end

    # @return [String, nil]
    def type
      raw_api_data['inventory_type']
    end

    # @return [Hash]
    def to_h
      {
        status: status, policy: policy, description: description, format: format, count: count,
        location: location, id: id, href: href, type: type
      }
    end
  end
end
