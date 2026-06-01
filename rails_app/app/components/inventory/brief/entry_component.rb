# frozen_string_literal: true

module Inventory
  module Brief
    # Component that displays a records availability information.
    class EntryComponent < ViewComponent::Base
      attr_accessor :entry

      delegate :href, :physical?, to: :entry

      # @param entry [Inventory::Entry]
      def initialize(entry:)
        @entry = entry
      end

      # @return [Boolean]
      def available?
        entry.status == Inventory::Constants::AVAILABLE
      end

      # Ordered list of fragments to render as the inline summary for this entry.
      # Each fragment is a Hash with :key (symbol used as a CSS modifier) and
      # :value (the display text). Blank values are pruned so the markup stays
      # clean when an entry is missing optional data.
      #
      # @return [Array<Hash>]
      def summary_fields
        fields_for_entry.reject { |f| f[:value].blank? }
      end

      # The electronic public note, surfaced separately so it can be opened in
      # a popover instead of bloating the inline summary.
      # @return [String, nil] sanitized HTML
      def note_content
        return nil unless entry.respond_to?(:public_note)

        entry.public_note.presence
      end

      # Classes to use in rendering the inventory entry element
      # @return [Array<String (frozen)>]
      def classes
        classes = ['fi-option']
        classes << if available? || !physical?
                     'fi-option--available'
                   elsif entry.status == Inventory::Constants::UNAVAILABLE
                     'fi-option--unavailable'
                   elsif entry.status == Inventory::Constants::CHECK_HOLDINGS
                     'fi-option--check-holdings'
                   else
                     'fi-option--other'
                   end
      end

      private

      # Dispatch summary_fields to the per-type field builder.
      # @return [Array<Hash>]
      def fields_for_entry
        return physical_fields if entry.physical?
        return resource_link_fields if entry.respond_to?(:resource_link?) && entry.resource_link?

        electronic_fields
      end

      def physical_fields
        [
          { key: :status,      value: entry.human_readable_status },
          { key: :location,    value: physical_location_value },
          { key: :call_number, value: entry.description }
        ]
      end

      def resource_link_fields
        [
          { key: :status,      value: entry.human_readable_status },
          { key: :description, value: entry.description }
        ]
      end

      def electronic_fields
        [
          { key: :status,     value: entry.human_readable_status },
          { key: :collection, value: entry.description },
          { key: :coverage,   value: entry.coverage_statement }
        ]
      end

      # Location string for the inline summary. For LIBRA holdings the location
      # is annotated with the access modifier so the patron sees the path
      # alongside the (otherwise opaque) library acronym.
      # @return [String, nil]
      def physical_location_value
        base = entry.human_readable_location
        return base if base.blank?
        return I18n.t('inventory.location_modifiers.offsite', location: base) if entry.location.libra?

        base
      end
    end
  end
end
