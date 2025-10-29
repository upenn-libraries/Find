# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests a fielded title search
    class TitleSearch < SuggestionEngine
      EngineRegistry.register(self)
      # @return [Integer]
      def self.weight
        5
      end

      # @return [Suggester::Suggestion]
      def actions
        Suggestion.new(entries: [{ label: label, url: url }], engine_weight: self.class.weight)
      end

      private

      # @return [String]
      def label
        I18n.t('suggestions.engines.title_search.label', query: query)
      end

      # @return [String]
      def url
        URI::HTTPS.build(host: Settings.suggestions.digital_catalog.host,
                         query: { search_field: 'title_search', q: query }.to_query).to_s
      end
    end
  end
end
