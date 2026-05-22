# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests a record page corresponding to an MMS ID
    class InternalIdentifier < Engine
      Registry.register(self)

      BASE_ACTIONS_WEIGHT = 30
      MMS_ID_PATTERN = /99\d+3681/

      # @param query [String]
      # @return [Boolean]
      def self.suggest?(query)
        query.match?(MMS_ID_PATTERN)
      end

      attr_reader :mms_id

      def initialize(query:, context: {})
        super
        @mms_id = query.scan(MMS_ID_PATTERN).first
      end

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new(
          entries: [
            Action.new(label: I18n.t('suggestions.engines.internal_identifier.label', query: @mms_id),
                       url: Rails.application.routes.url_helpers.solr_document_path(id: @mms_id))
          ],
          engine_weight: self.class.actions_weight
        )
      end
    end
  end
end
