# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions
    # This is a dummy version, ultimately we will contact Solr for title suggestions
    class TitleCompletion < Engine
      Registry.register(self)

      BASE_WEIGHT = 10

      # @return [Integer]
      def self.weight
        BASE_WEIGHT
      end

      # @return [Suggester::Suggestions::Suggestion]
      def completions
        Suggestions::Suggestion.new(entries: [%(Title containing <b>#{query}</b>),
                                              %(Another title containing <b>#{query}</b>)])
      end
    end
  end
end
