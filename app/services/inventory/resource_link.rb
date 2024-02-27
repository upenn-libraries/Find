# frozen_string_literal: true

module Inventory
  # Represents an inventory entry that comes from the MARC record
  class ResourceLink < Inventory::Base
    attr_reader :href, :description

    # @param [Integer] id
    # @param [String] href
    # @param [String] description
    def initialize(id:, href:, description:)
      @id = id
      @href = href
      @description = description
    end

    # @return [nil]
    def count
      nil
    end

    # @return [String]
    def location
      'Online'
    end

    # @return [String]
    def type
      Inventory::Service::RESOURCE_LINK
    end

    # @return [String]
    def status
      'available'
    end
  end
end
