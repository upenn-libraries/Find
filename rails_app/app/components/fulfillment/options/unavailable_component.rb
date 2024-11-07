# frozen_string_literal: true

module Fulfillment
  module Options
    # Component to render information for getting at an unavailable item
    class UnavailableComponent < ViewComponent::Base
      attr_accessor :item

      def initialize(item:)
        @item = item
      end

      def render
        tag.p t('requests.form.options.only_ill_requestable')
      end
    end
  end
end
