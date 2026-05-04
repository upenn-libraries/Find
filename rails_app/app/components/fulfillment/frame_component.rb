# frozen_string_literal: true

module Fulfillment
  # Lazy-loaded frame for retrieving fulfillment options.
  class FrameComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_reader :frame_id

    def initialize(form_params:, frame_id:)
      @form_params = form_params
      @frame_id = frame_id
    end

    private

    def fulfillment_form_params
      @form_params.merge(frame_id: frame_id)
    end
  end
end
