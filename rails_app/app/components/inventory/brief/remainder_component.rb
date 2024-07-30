# frozen_string_literal: true

module Inventory
  module Brief
    # Component that displays the number of inventory entries _NOT_ displayed
    class RemainderComponent < ViewComponent::Base
      attr_reader :document

      def initialize(document)
        @document = document
      end

      # Number of additional entries available.
      # @return [Integer]
      def remainder_count
        @remainder_count ||= calculate_remainder
      end

      def render?
        remainder_count.positive?
      end

      def call
        tag.li do
          link_to solr_document_path(document.id), class: 'holdings__other-link' do
            t('inventory.see_all', count: remainder_count, options: 'option'.pluralize(remainder_count))
          end
        end
      end

      private

      # Determine the number of inventory entries _NOT_ displayed based on the information in the SolrDocument.
      def calculate_remainder
        resource_link_remainder = [document.marc_resource_links.count - Inventory::List::RESOURCE_LINK_LIMIT, 0].max
        inventory_remainder = [document.inventory_count - Inventory::List::DEFAULT_LIMIT, 0].max
        resource_link_remainder + inventory_remainder
      end
    end
  end
end
