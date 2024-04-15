# frozen_string_literal: true

module Account
  module Requests
    # renders form for new request
    class FormComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_accessor :holdings, :items

      def initialize(mms_id:, holding_id:, holdings:, items:, alma_user:)
        @mms_id = mms_id
        @holding_id = holding_id
        @holdings = holdings
        @items = items
        @alma_user = alma_user
      end

      def holding_labels
        holdings.map do |holding|
          [[holding['library'], holding['call_number']].compact_blank.join(' - '), holding['holding_id']]
        end
      end

      def item_labels
        items.map(&:select_label)
      end
    end
  end
end
