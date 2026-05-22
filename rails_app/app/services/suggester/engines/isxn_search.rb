# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests an ISBN/ISSN search
    class IsxnSearch < Engine
      Registry.register(self)

      BASE_ACTIONS_WEIGHT = 25
      ISXN_PATTERN = /\d{8,}/

      # @param query [String]
      # @return [Boolean]
      def self.suggest?(query)
        !InternalIdentifier.suggest?(query) && query.match?(ISXN_PATTERN)
      end

      attr_reader :isxn

      def initialize(query:, context: {})
        super
        @isxn = query.scan(ISXN_PATTERN).first
      end

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new(
          entries: [
            Action.new(label: I18n.t('suggestions.engines.isxn_search.label', query: @isxn),
                       url: URI::HTTPS.build(host: Settings.suggester.digital_catalog.host,
                                             query: { search_field: 'isxn_search', q: @isxn }
                                                      .to_query).to_s)
          ],
          engine_weight: self.class.actions_weight
        )
      end
    end
  end
end
