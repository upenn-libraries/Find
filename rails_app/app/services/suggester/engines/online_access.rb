# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests a search for the query within 'Online Access'
    class OnlineAccess < SuggestionEngine
      EngineRegistry.register(self)

      # @return [Integer]
      def self.weight
        2
      end

      # @return [Suggester::Suggestion]
      def actions
        Suggestion.new(entries: [{ label: label,
                                   url: URI::HTTPS.build(host: Settings.suggestions.digital_catalog.host,
                                                         query: {
                                                           "f[access_facet][]": 'Online', q: query
                                                         }.to_query).to_s }],
                       engine_weight: self.class.weight)
      end

      private

      # @return [String]
      def label
        I18n.t('suggestions.engines.online_access_search.label', query: query)
      end
    end
  end
end
