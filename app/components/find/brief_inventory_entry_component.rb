# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class BriefInventoryEntryComponent < ViewComponent::Base
    attr_accessor :data

    # @param [Hash] data
    def initialize(data:)
      @data = data
    end

    # @return [Boolean]
    def physical?
      data[:type] == 'physical'
    end

    # @return [Boolean]
    def available?
      data[:status] == 'available'
    end

    # @return [String]
    def header_content
      return unless physical?

      join_fields status, data[:location]
    end

    # @return [String]
    def main_content
      join_fields data[:format], data[:description]
    end

    # @return [String]
    def footer_content
      return if physical?

      join_fields status
    end

    # @return [String]
    def href
      data[:href]
    end

    # User-friendly display value for inventory entry status
    # @return [String] status
    def status
      return I18n.t('inventory.entries.status.check_holdings') if data[:status] == 'check_holdings'
      return I18n.t('inventory.entries.status.unavailable') unless available?
      return I18n.t('inventory.entries.status.available_electronic') if available? && !physical?
      return I18n.t('inventory.entries.status.available_physical') if available? && physical?

      data[:status].capitalize
    end

    # Classes to use in rendering the inventory entry element
    # @return [Array<String (frozen)>]
    def classes
      classes = ['holding__item']
      classes << if available?
                   'holding__item--available'
                 elsif data[:status] == 'unavailable'
                   'holding__item--unavailable'
                 elsif data[:status] == 'check_holdings'
                   'holding__item--check_holdings'
                 else
                   'holding__item--other'
                 end
    end

    private

    # @param [Array] fields
    # @return [String]
    def join_fields(*fields)
      fields.compact_blank.join(' - ')
    end
  end
end
