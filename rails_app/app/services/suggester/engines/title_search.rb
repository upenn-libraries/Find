# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests a fielded title search
    class TitleSearch < Engine
      Registry.register(self)

      BASE_WEIGHT = 5
      # @return [Integer]
      def self.weight
        BASE_WEIGHT
      end

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new(entries: [{ label: label, url: url }], engine_weight: self.class.weight)
      end

      private

      # @return [String]
      def label
        I18n.t('suggestions.engines.title_search.label', query: query)
      end

      # @return [String]
      def url
        URI::HTTPS.build(host: Settings.suggester.digital_catalog.host,
                         query: { search_field: 'title_search', q: query }.to_query).to_s
      end
    end
  end
end
