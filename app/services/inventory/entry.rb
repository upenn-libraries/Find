# frozen_string_literal: true

module Inventory
  # Abstract class that all Inventory entry classes inherit from. Establishes API that subclasses should adhere to.
  class Entry
    PHYSICAL = 'physical'
    ELECTRONIC = 'electronic'
    RESOURCE_LINK = 'resource_link'

    attr_reader :data, :mms_id

    # @param mms_id [String]
    # @param data [Hash] hash containing inventory data retrieved from Alma real time availability API
    # See Alma::AvailabilityResponse for mapping of values into the raw_availability_data hash
    def initialize(mms_id:, **data)
      @mms_id = mms_id
      @data = data
    end

    # User-friendly display value for inventory entry status
    # @return [String] status
    def human_readable_status
      return I18n.t('alma.availability.available.physical.status') if available? && physical?
      return I18n.t('alma.availability.available.electronic.status') if available? && !physical?
      return I18n.t('alma.availability.check_holdings.physical.status') if status == Constants::CHECK_HOLDINGS
      return I18n.t('alma.availability.unavailable.physical.status') if status == Constants::UNAVAILABLE

      entry.status.capitalize
    end

    def id
      raise NotImplementedError
    end

    def description
      raise NotImplementedError
    end

    def status
      raise NotImplementedError
    end

    def location
      raise NotImplementedError
    end

    def policy
      raise NotImplementedError
    end

    def format
      raise NotImplementedError
    end

    def coverage_statement
      raise NotImplementedError
    end

    def href
      raise NotImplementedError
    end

    # @return [Boolean]
    def electronic?
      false
    end

    # @return [Boolean]
    def physical?
      false
    end

    # @return [Boolean]
    def resource_link?
      false
    end
  end
end
