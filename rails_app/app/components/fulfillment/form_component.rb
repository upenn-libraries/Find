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

    # Sort items so the best candidate appears first in the dropdown.
    # In-place items rank above unavailable ones; likely-loanable items break ties.
    # @param items [Array<Inventory::Item>]
    # @return [Array<Inventory::Item>]
    def sort_items(items)
      items.sort_by do |item|
        options = Fulfillment::OptionsSet.new(item: item, user: @user)
        [item.in_place? ? 0 : 1, options.likely_loanable? ? 0 : 1]
      end
    end
  end
end
