# frozen_string_literal: true

module Inventory
  # Base class that all Inventory classes inherit from. Defines methods that each entry should define.
  class Entry
    PHYSICAL = 'physical'
    ELECTRONIC = 'electronic'
    RESOURCE_LINK = 'resource_link'

    attr_reader :data, :mms_id

    # @param [String] mms_id
    # @param [Hash] data hash containing inventory data retrieved from Alma real time availability API
    # See Alma::AvailabilityResponse for mapping of values into the raw_availability_data hash
    def initialize(mms_id:, **data)
      @mms_id = mms_id
      @data = data
    end

    def description
      raise NotImplementedError
    end

    def status
      raise NotImplementedError
    end

    def id
      raise NotImplementedError
    end

    def href
      raise NotImplementedError
    end

    def format
      raise NotImplementedError
    end

    def location
      raise NotImplementedError
    end

    # @return [String, nil]
    def type
      data[:inventory_type]
    end

    def electronic?
      type == ELECTRONIC
    end

    def physical?
      type == PHYSICAL
    end

    def resource_link?
      type == RESOURCE_LINK
    end
  end
end
