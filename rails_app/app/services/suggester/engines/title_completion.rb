# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions
    # This is a dummy version, ultimately we will contact Solr for title suggestions
    class TitleCompletion < Engine
      Registry.register(self)

      # @return [Integer]
      def self.weight
        2
      end

      # @return [Suggester::Suggestions::Suggestion]
      def completions
        Suggestions::Suggestion.new(entries: [%(Title containing <b>#{query}</b>),
                                              %(Another title containing <b>#{query}</b>)])
      end
    end
  end
end
