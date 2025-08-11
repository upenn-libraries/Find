# frozen_string_literal: true

module Fulfillment
  module Choices
    # Wharton DocDel component logic
    class DocdelComponent < ViewComponent::Base
      attr_accessor :user, :checked, :radio_options

      def initialize(user:, checked: false, **radio_options)
        @user = user
        @checked = checked
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Options::Deliverable::DOCDEL
      end
    end
  end
end
