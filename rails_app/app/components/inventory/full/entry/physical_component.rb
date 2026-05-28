# frozen_string_literal: true

module Inventory
  module Full
    module Entry
      # Component rendering the full view of a Physical entry.
      class PhysicalComponent < ViewComponent::Base
        attr_reader :entry, :user

        # @param entry [Inventory::Entry]
        # @param user [User] user is necessary to show `Log in to request item`
        # @param policy [Inventory::LocationPolicy, nil]
        def initialize(entry:, user: nil, policy: nil)
          @entry = entry
          @user = user
          @policy = policy
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

        # @return [Inventory::LocationPolicy]
        def policy
          @policy || entry.location.policy
        end

        # Return true if request options are only available after login
        def require_authentication_for_requesting?
          user.nil? && policy.requires_authentication?
        end

        # @return [Hash] parameters for the fulfillment form
        def fulfillment_form_params
          {
            mms_id: entry.mms_id,
            holding_id: entry.id,
            host_record_id: entry.host_record_id,
            location_code: entry.location.code
          }
        end
      end
    end
  end
end
