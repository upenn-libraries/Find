# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_accessor :item, :user, :options

      def initialize(user:, options:)
        @user = user
        @options = options.inquiry
      end

      # Returns true if at least one delivery option is available.
      def deliverable?
        options.any?(:scan, :pickup, :mail, :office)
      end
    end
  end
end
