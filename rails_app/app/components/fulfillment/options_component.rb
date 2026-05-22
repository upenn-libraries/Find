# frozen_string_literal: true

module Fulfillment
  # Renders the available options - or lack thereof - for physical holdings
  class OptionsComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :options

    delegate :user, :item, :deliverable?, :restricted?, to: :options

    # @param options_set [Fulfillment::OptionsSet]
    def initialize(options_set:)
      @options = options_set
    end
  end
end
