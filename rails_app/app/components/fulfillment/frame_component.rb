# frozen_string_literal: true

module Fulfillment
  # Lazy-loaded frame for retrieving fulfillment options.
  class FrameComponent < ViewComponent::Base
    include Turbo::FramesHelper

    # @param form_params [Hash] parameters passed to the fulfillment form
    def initialize(form_params:)
      @form_params = form_params
    end
  end
end
