# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions
    # This is a dummy version, ultimately we will contact Solr for title suggestions
    class TitleCompletion < Engine
      Registry.register(self)

      BASE_WEIGHT = 10

      def self.suggest?(_query)
        false
      end

      # @return [Integer]
      def self.weight
        BASE_WEIGHT
      end
    end
  end
end
