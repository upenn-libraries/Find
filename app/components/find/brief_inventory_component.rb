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

    def remainder
      document.inventory_count - skeleton_entries
    end

    def skeleton_entries
      [document.inventory_count, Inventory::Service::DEFAULT_LIMIT].min
    end

    # Get "full text link" (856 with indicator 0 or 1) values and render them using the
    # view component used in the dynamic inventory rendering
    # @return [String]
    def resource_link_entries
      return if document.blank?

      marc_entries = Inventory::Service.resource_links(document).entries
      return unless marc_entries.any?

      li_elements = marc_entries.map do |entry|
        render(Find::BriefInventoryEntryComponent.new(entry: entry))
      end
      return if li_elements.blank?

      safe_join li_elements
    end
  end
end
