# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions
    # This is a dummy version, ultimately we will contact Solr for title suggestions
    class TitleCompletion < SuggestionEngine
      EngineRegistry.register(self)

      # @return [Integer]
      def self.weight
        2
      end

      # @return [Suggester::Suggestion]
      def completions
        Suggestion.new(entries: [%(Title containing <b>#{query}</b>), %(Another title containing <b>#{query}</b>)])
      end
    end
  end
end
