# frozen_string_literal: true

module Fulfillment
  # Lazy-loaded frame for retrieving fulfillment options.
  class FrameComponent < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(mms_id:, holding_id:, host_record_id:, location_code:)
      @mms_id = mms_id
      @holding_id = holding_id
      @host_record_id = host_record_id
      @location_code = location_code
    end

    private

    def fulfillment_form_params
      {
        mms_id: @mms_id,
        holding_id: @holding_id,
        host_record_id: @host_record_id,
        location_code: @location_code
      }
    end
  end
end
