# frozen_string_literal: true

module Account
  module Requests
    # conditional buttons based on item selection
    class ButtonsComponent < ViewComponent::Base
      attr_accessor :options

      def initialize(options:)
        @options = options
      end
    end
  end
end
