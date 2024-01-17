# frozen_string_literal: true

module Inventory
  # Base class that all Inventory classes inherit from
  class Base

    attr_reader :status, :policy, :description, :format, :count, :location, :id, :href, :type

    def initialize(mms_id, raw_api_data)
      @mms_id = mms_id
      @raw_api_data = raw_api_data
    end

    # Factory class method to create Inventory subclasses
    def self.create; end

    # @return [Hash]
    def to_h
      {
        status: status, policy: policy, description: description, format: format, count: count,
        location: location, id: id, href: href, type: type
      }
    end
  end
end
