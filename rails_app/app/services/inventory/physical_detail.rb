# frozen_string_literal: true

module Inventory
  # Grab additional data for physical record holdings
  class PhysicalDetail
    attr_accessor :mms_id, :holding_id

    def initialize(mms_id:, holding_id:)
      @mms_id = mms_id
      @holding_id = holding_id
    end

    # Public note value from Holding MARC
    # @return [String, nil]
    def notes
      holding&.public_note
    end

    private

    def holding
      @holding ||= Service::Physical.holding(mms_id: mms_id, holding_id: holding_id)
    end
  end
end
