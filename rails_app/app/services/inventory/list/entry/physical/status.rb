# frozen_string_literal: true

module Inventory
  class List
    module Entry
      class Physical
        # Translating Alma statuses for physical holdings to a user-friendly status label and description. For all three
        # statuses ("available", "check_holdings", and "unavailable") we provide a more specific status label and
        # description based on location. For example, material at one Penn location can only be accessed by request
        # even though Alma reports it as "Available". This class adjusts the terminology used when labeling
        # availability so that it displays appropriate guidance for the holding's location.
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
          # @return [String]
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
                             when Constants::AVAILABLE then [:available, location.available_status_key]
                             when Constants::CHECK_HOLDINGS then [:check_holdings, location.check_holdings_status_key]
                             when Constants::UNAVAILABLE then [:unavailable, location.unavailable_status_key].compact
                             end
          end
        end
      end
    end
  end
end
