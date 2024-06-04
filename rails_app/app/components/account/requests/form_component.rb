# frozen_string_literal: true

module Account
  module Requests
    # renders form for new request
    class FormComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_accessor :items

      def initialize(mms_id:, holding_id:, items:)
        @mms_id = mms_id
        @holding_id = holding_id
        @items = items
      end

      def item_labels
        # This may need a more sophisticated sorting mechanism, but default sort works better than no sort at all.
        items.map(&:select_label).sort
      end
    end
  end
end
