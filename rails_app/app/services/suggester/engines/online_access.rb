# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests a search for the query within 'Online Access'
    class OnlineAccess < Engine
      Registry.register(self)

      BASE_ACTIONS_WEIGHT = 2

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new(
          entries: [
            Action.new(
              label: label,
              url: URI::HTTPS.build(host: Settings.suggester.digital_catalog.host,
                                    query: { "f[access_facet][]": 'Online', q: query }.to_query).to_s
            )
          ], engine_weight: self.class.actions_weight
        )
      end

      private

      # @return [String]
      def label
        I18n.t('suggestions.engines.online_access_search.label', query: query)
      end
    end
  end
end
