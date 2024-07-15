# frozen_string_literal: true

module Find
  # Component that displays a records inventory information.
  class BriefInventoryComponent < ViewComponent::Base
    attr_reader :id, :document

    # @param document [SolrDocument]
    def initialize(document:)
      @id = document.id
      @document = document
    end

    # Determine the number of inventory entries _NOT_ displayed
    # @return [Integer]
    def remainder_count
      resource_link_remainder = [document.marc_resource_links.count - Inventory::List::RESOURCE_LINK_LIMIT, 0].max
      inventory_remainder = [document.inventory_count - Inventory::List::DEFAULT_LIMIT, 0].max
      resource_link_remainder + inventory_remainder
    end

    # Determine the number of "skeleton" entries to render
    # @return [Integer]
    def skeleton_entry_count
      [document.inventory_count, Inventory::List::DEFAULT_LIMIT].min
    end

    # Get "full text link" (856 with indicator 0 or 1) values and render them using the
    # view component used in the dynamic inventory rendering
    # @return [String]
    def resource_link_entries
      return if document.blank?

      marc_entries = Inventory::List.resource_links(document)
      return unless marc_entries.any?

      li_elements = marc_entries.map do |entry|
        render(Find::BriefInventoryEntryComponent.new(entry: entry))
      end
      return if li_elements.blank?

      safe_join li_elements
    end
  end
end
