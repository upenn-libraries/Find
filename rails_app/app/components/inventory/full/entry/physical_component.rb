# frozen_string_literal: true

module Inventory
  module Full
    module Entry
      # Component rendering the full view of a Physical entry.
      class PhysicalComponent < ViewComponent::Base
        include Turbo::FramesHelper

        attr_reader :entry, :user

        # @param entry [Inventory::Entry]
        # @param user [User] user is necessary to show `Log in to request item`
        def initialize(entry:, user: nil)
          @entry = entry
          @user = user
        end

        # Class to use when rendering the availability summary
        # @return [String]
        def availability_class
          if entry.status == Inventory::Constants::AVAILABLE
            'inventory-item__availability--easy'
          elsif entry.status == Inventory::Constants::UNAVAILABLE
            'inventory-item__availability--difficult'
          else
            'inventory-item__availability'
          end
        end

        # Return true if request options are only available after login
        def require_authentication_for_requesting?
          user.nil? && !entry.location.aeon? && !entry.location.archives? && !entry.location.hsp?
        end
      end
    end
  end
end
