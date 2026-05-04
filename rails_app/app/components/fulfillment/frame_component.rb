# frozen_string_literal: true

module Fulfillment
  # Lazy-loaded frame for retrieving fulfillment options.
  class FrameComponent < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(form_params:)
      @form_params = form_params
    end

    private

    def fulfillment_form_params
      @form_params
    end
  end
end
