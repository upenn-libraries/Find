# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class BriefInventoryEntryComponent < ViewComponent::Base
    attr_accessor :entry

    delegate :href, :physical?, to: :entry

    # @param entry [Inventory::Entry]
    def initialize(entry:)
      @entry = entry
    end

    # @return [Boolean]
    def available?
      entry.status == 'available'
    end

    # @return [String]
    def header_content
      return unless physical?

      join_fields status
    end

    # @return [String]
    def main_content
      join_fields entry.description
    end

    # @return [String]
    def footer_content
      fields = [entry.format, entry.location]
      fields << entry.coverage_statement if entry.electronic?
      join_fields(*fields)
    end

    # User-friendly display value for inventory entry status
    # @return [String] status
    def status
      return I18n.t('inventory.entries.status.check_holdings') if entry.status == 'check_holdings'
      return I18n.t('inventory.entries.status.unavailable') unless available?
      return I18n.t('inventory.entries.status.available_electronic') if available? && !physical?
      return I18n.t('inventory.entries.status.available_physical') if available? && physical?

      entry.status.capitalize
    end

    # Classes to use in rendering the inventory entry element
    # @return [Array<String (frozen)>]
    def classes
      classes = ['holding__item']
      classes << if available?
                   'holding__item--available'
                 elsif entry.status == 'unavailable'
                   'holding__item--unavailable'
                 elsif entry.status == 'check_holdings'
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
