# frozen_string_literal: true

module Fulfillment
  # renders form for new request
  class FormComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :items

    attr_reader :frame_id

    def initialize(mms_id:, holding_id:, items:, user:, frame_id: 'form_frame')
      @mms_id = mms_id
      @holding_id = holding_id
      @items = items
      @user = user
      @frame_id = frame_id
    end

    def item_labels
      items.map(&:select_label)
    end
  end
end
