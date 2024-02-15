# frozen_string_literal: true

module Find
  # Component that displays a records inventory information.
  class InventoryComponent < ViewComponent::Base
    # @param record_id [String]
    # @param [Hash, nil] inventory
    # @param count [String] number of entries to display
    # @param [SolrDocument] document
    def initialize(record_id:, count: nil, inventory: nil, document: nil)
      @id = record_id
      @count = count || inventory[:count]
      @entries = inventory[:inventory] if inventory
      @document = document
    end

    def static_entries
      return unless @document

      li_elements = @document.inventory_link_data&.map do |link_data|
        render(Find::InventoryEntryComponent.new(data: {
                                                   type: 'electronic', status: 'available', location: 'Online',
                                                   description: link_data[:link_text], href: link_data[:link_url]
                                                 }))
      end
      return if li_elements.blank?

      safe_join li_elements
    end
  end
end
