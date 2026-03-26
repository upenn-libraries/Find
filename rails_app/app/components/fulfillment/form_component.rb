# frozen_string_literal: true

module Fulfillment
  # renders form for new request
  class FormComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :items

    def initialize(mms_id:, holding_id:, items:, user:)
      @mms_id = mms_id
      @holding_id = holding_id
      @items = sort_items(items)
      @user = user
    end

    def item_labels
      items.map(&:select_label)
    end

    private

    # Sort items so in-place (available) items appear first in the dropdown,
    # ensuring the pre-selected first item is requestable.
    # @param items [Array<Inventory::Item>]
    # @return [Array<Inventory::Item>]
    def sort_items(items)
      items.sort_by { |item| item.in_place? ? 0 : 1 }
    end
  end
end
