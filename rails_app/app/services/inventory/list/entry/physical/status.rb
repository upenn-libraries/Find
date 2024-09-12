# frozen_string_literal: true

module Inventory
  class List
    module Entry
      class Physical
        # Translating Alma statuses for physical holdings to a user-friendly status label and description. If the status
        # is "available" or "check_holdings" we provide a more specific status label and description based on
        # its location. For example, material at one Penn location can only be accessed by request even though Alma
        # reports it as "Available". This class adjusts the terminology used when labeling availability so that it
        # displays appropriate guidance for the holding's location.
        class Status
          attr_accessor :status, :location

          # @param status [String]
          # @param location [Inventory::Location]
          def initialize(status:, location:)
            @status = status
            @location = location
          end

          # Return user-friendly status.
          #
          # @return [String, nil]
          def label
            if i18n_namespace.blank?
              status&.capitalize
            else
              I18n.t(:label, scope: i18n_namespace)
            end
          end

          # Return user-friendly status description.
          #
          # @return [String, NilClass]
          def description
            return if i18n_namespace.blank?

            I18n.t(:description, scope: i18n_namespace)
          end

          private

          # Return complete namespace/scope for I18n translation.
          #
          # @return [Array<Symbol>]
          def i18n_namespace
            return [] if status_keys.blank?

            %i[alma availability physical].concat(status_keys)
          end

          # Return keys used to look up detailed status in locales.
          #
          # @return [Array<Symbol>]
          def status_keys
            @status_keys ||= case status
                             when Constants::AVAILABLE then [:available, refined_available_key]
                             when Constants::CHECK_HOLDINGS then [:check_holdings, refined_check_holdings_key]
                             when Constants::UNAVAILABLE then [:unavailable]
                             end
          end

          # Return a refined available status key, because some things Alma reports as available are available only
          # under some restrictions we want to make explicit in our status display. Order of the logic here matters, so
          # that items at LIBRA that require an Aeon Request are properly handled, for example.
          # @return [Symbol]
          def refined_available_key
            if location.aeon?
              :appointment
            elsif location.libra?
              :offsite
            elsif location.archives? || location.hsp?
              :unrequestable
            else
              :circulates
            end
          end

          # Return a refined check holdings status key.
          #
          # This status means that some items are available and some are not. For most items, displaying a "mixed
          # availability" message is accurate but in the case of items that are only available by appointment
          # it's clearer for the user to display the "available via appointment" message.
          def refined_check_holdings_key
            if location.aeon?
              :appointment
            else
              :mixed_availability
            end
          end
        end
      end
    end
  end
end
