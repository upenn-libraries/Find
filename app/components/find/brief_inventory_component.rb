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
    def remainder
      subtrahend = if document.marc_resource_links.any?
                     skeleton_entries +
                       [Inventory::Service::RESOURCE_LINK_LIMIT, document.marc_resource_links.count].min
                   else
                     skeleton_entries
                   end
      document.inventory_count - subtrahend
    end

    def skeleton_entries
      [document.inventory_count, Inventory::Service::DEFAULT_LIMIT].min
    end

    # Get "full text link" (856 with indicator 0 or 1) values and render them using the
    # view component used in the dynamic inventory rendering
    # @return [String]
    def resource_link_entries
      return if document.blank?

      marc_entries = Inventory::Service.resource_links(document)
      return unless marc_entries.any?

      li_elements = marc_entries.map do |entry|
        render(Find::BriefInventoryEntryComponent.new(entry: entry))
      end
      return if li_elements.blank?

      safe_join li_elements
    end
  end
end
