# frozen_string_literal: true

module Inventory
  # Component that renders a turbo-frame that requests a record's brief inventory information.
  #
  # This component displays the information available without making extra API calls and displays a skeleton for
  # the missing information.
  class BriefSkeletonComponent < ViewComponent::Base
    attr_reader :id, :document

    # @param document [SolrDocument]
    def initialize(document:)
      @id = document.id
      @document = document
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
        render(Inventory::Brief::EntryComponent.new(entry: entry))
      end
      return if li_elements.blank?

      safe_join li_elements
    end
  end
end
