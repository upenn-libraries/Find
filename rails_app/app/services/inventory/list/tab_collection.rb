# frozen_string_literal: true

module Inventory
  class List
    # A list of inventory tabs
    class TabCollection
      def initialize(inventory:)
        @inventory = inventory
      end

      delegate :complete?, to: :@inventory

      delegate :entries, to: :@inventory

      def tabs
        @tabs ||= begin
          group_tabs = grouped_resource_links.map do |hostname, links|
            Tab.new(entries: links, group_key: hostname.parameterize.underscore)
          end
          single_entry_tabs = single_entries.map { |entry| Tab.new(entries: [entry]) }

          group_tabs + single_entry_tabs
        end
      end

      def active?(id, tab)
        if id.blank?
          tab.id == tabs.first.id
        else
          id == tab.id
        end
      end

      private

      def grouped_resource_links
        entries.select(&:resource_link?)
               .select(&:hostname)
               .group_by(&:hostname)
               .select { |_hostname, resource_links| resource_links.size > 1 }
      end

      def single_entries
        entries - grouped_resource_links.values.flatten
      end
    end
  end
end
