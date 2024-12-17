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

      # @return [String]
      def header_content
        return unless physical?

        join_fields entry.human_readable_status
      end

      # @return [String]
      def main_content
        join_fields entry.description
      end

      # @return [String, nil]
      def public_note_content
        entry.data[:public_note] if entry.electronic?
      end

      # @return [String]
      def footer_content
        fields = [entry.human_readable_location]
        fields << entry.coverage_statement if entry.electronic?
        join_fields(*fields)
      end

      # Classes to use in rendering the inventory entry element
      # @return [Array<String (frozen)>]
      def classes
        classes = ['holding__item']
        classes << if available? || !physical?
                     'holding__item--available'
                   elsif entry.status == Inventory::Constants::UNAVAILABLE
                     'holding__item--unavailable'
                   elsif entry.status == Inventory::Constants::CHECK_HOLDINGS
                     'holding__item--check-holdings'
                   else
                     'holding__item--other'
                   end
      end

      private

      # @param fields [Array]
      # @return [String]
      def join_fields(*fields)
        fields.compact_blank.join(' - ')
      end
    end
  end
end
