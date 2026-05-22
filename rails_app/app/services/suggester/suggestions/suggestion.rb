# frozen_string_literal: true

module Suggester
  module Suggestions
    # Object that Engine classes use to represent their suggestions
    class Suggestion
      attr_reader :entries, :engine_weight, :weight

      delegate :present?, :blank?, :size, to: :entries

      # @param entries [Array]
      # @param engine_weight [Integer]
      # @param weight [Integer]
      def initialize(entries: [], engine_weight: 0, weight: 0)
        @entries = entries
        @engine_weight = engine_weight
        @weight = weight
      end

      # Provide entries without duplicates
      # @return [Array]
      def provide
        entries.uniq
      end

      # @return [Integer]
      def score
        engine_weight + weight
      end

      # @return [Integer]
      def <=>(other)
        score <=> other.score
      end
    end
  end
end
