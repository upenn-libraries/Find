# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class BriefInventoryEntryComponent < ViewComponent::Base
    attr_accessor :entry

    delegate :href, to: :entry

    # @param entry [Inventory::Entry]
    def initialize(entry:)
      @entry = entry
    end

    # @return [Boolean]
    def physical?
      entry.type == Inventory::Entry::PHYSICAL
    end

    # @return [Boolean]
    def available?
      entry.status == Inventory::Constants::AVAILABLE
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
      if entry.status == Inventory::Constants::CHECK_HOLDINGS
        return I18n.t('alma.availability.check_holdings.physical.status')
      end
      return I18n.t('alma.availability.unavailable.physical.status') unless available?
      return I18n.t('alma.availability.available.electronic.status') if available? && !physical?
      return I18n.t('alma.availability.available.physical.status') if available? && physical?

      entry.status.capitalize
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
