# frozen_string_literal: true

module Suggester
  module Suggestions
    # Provides interface for requesting suggestions from a collection of SuggestionEngines
    class Collection
      attr_reader :suggestions

      # @param suggestions [Array<Suggester::Suggestions::Suggestion>]
      def initialize(suggestions: [])
        @suggestions = suggestions.compact_blank.sort.reverse
      end

      # @param limit [Integer]
      # @return [Array]
      def provide(limit: total_entries)
        suggestions.flat_map(&:provide).first(limit)
      end

      # @return [Boolean]
      def present?
        suggestions.any?(&:present?)
      end

      private

      def total_entries
        suggestions.map(&:size).sum
      end
    end
  end
end
