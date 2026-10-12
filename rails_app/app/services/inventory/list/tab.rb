# frozen_string_literal: true

module Inventory
  class List
    # Represents an inventory tab
    class Tab
      GROUPED_RESOURCE_ID_PREFIX = 'multipart_'

      attr_reader :entries

      def initialize(entries:, group_key: nil)
        @entries = entries
        @group_key = group_key
      end

      # Delegate entry methods to a primary entry
      # @return [Inventory::List::Entry::Base]
      def primary
        @primary ||= @entries.first
      end

      # @return [String]
      def id
        return primary.id unless grouped?

        "#{GROUPED_RESOURCE_ID_PREFIX}#{@group_key}"
      end

      # @return [String, nil]
      def description
        @entries.filter_map(&:description).uniq.join(', ')
      end

      # @return [String, nil]
      def coverage_statement
        coverage = @entries.filter_map(&:coverage_statement)

        return if coverage.blank?

        coverage.join(', ')
      end

      def grouped?
        @entries.many?
      end

      private

      def method_missing(method, *args, &block)
        primary.public_send(method, *args, &block)
      end

      def respond_to_missing?(method)
        primary.respond_to?(method)
      end
    end
  end
end
