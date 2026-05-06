# frozen_string_literal: true

module Fulfillment
  # renders form for new request
  class FormComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :items

    def initialize(mms_id:, holding_id:, items:, user:)
      @mms_id = mms_id
      @holding_id = holding_id
      @items = items
      @user = user
    end

    def item_labels
      items.map(&:select_label)
    end
  end
end
