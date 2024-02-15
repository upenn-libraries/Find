# frozen_string_literal: true

module Find
  # Component that displays a records inventory information.
  class BriefInventoryComponent < ViewComponent::Base
    # @param record_id [String]
    # @param [Hash, nil] inventory
    # @param count [String] number of inventory entries from SolrDocument
    # @param [SolrDocument] document
    def initialize(record_id:, count: nil, inventory: nil, document: nil)
      @id = record_id
      @entries = inventory[:inventory] if inventory
      @total_count = inventory ? inventory[:count] : count
      @display_count = @entries&.length
      @document = document
    end

    # @return [Boolean]
    def inventory_present?
      @total_count.positive?
    end

    def static_entries
      return unless @document

      li_elements = @document.inventory_link_data&.map do |link_data|
        render(Find::BriefInventoryEntryComponent.new(
                 data: { type: 'electronic', status: 'available', location: 'Online',
                         description: link_data[:link_text], href: link_data[:link_url] }
               ))
      end
      return if li_elements.blank?

      safe_join li_elements
    end

    # @return [Integer]
    def show_more_count
      @total_count - skeleton_count
    end

    # Skeleton should never show more than the brief_count from Inventory::Service
    # @return [Integer, nil]
    def skeleton_count
      return unless @total_count

      [@total_count, Inventory::Service::BRIEF_RECORD_COUNT].min
    end
  end
end
