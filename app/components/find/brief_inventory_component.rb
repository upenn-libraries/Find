# frozen_string_literal: true

module Find
  # Component that displays a records inventory information.
  class BriefInventoryComponent < ViewComponent::Base
    # @param record_id [String]
    # @param inventory [Hash, nil]
    # @param count [String]number of inventory entries from SolrDocument
    # @param document [SolrDocument]
    def initialize(record_id:, count: nil, inventory: nil, document: nil)
      @id = record_id
      @entries = inventory[:inventory] if inventory
      @total_count = inventory ? inventory[:count] : count
      @display_count = @entries&.length
      @document = document
    end

    # Get "full text link" (856 with indicator 0 or 1) values and render them using the
    # view component used in the dynamic inventory rendering
    # @return [String]
    def resource_link_entries
      return if @document.blank?

      marc_entries = Inventory::Service.find_in_marc(@document).entries
      return unless marc_entries.any?

      li_elements = marc_entries.map do |entry|
        render(Find::BriefInventoryEntryComponent.new(data: entry))
      end
      return if li_elements.blank?

      safe_join li_elements
    end

    # How many entries are _not_ displayed?
    # @return [Integer]
    def show_more_count
      @show_more_count ||= @total_count - skeleton_count
    end

    # Skeleton should never show more than the brief_count from Inventory::Service
    # @return [Integer, nil]
    def skeleton_count
      return unless @total_count

      [@total_count, Inventory::Service::DEFAULT_LIMIT].min
    end
  end
end
