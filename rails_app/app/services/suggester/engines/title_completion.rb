# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions from a solr suggestions endpoint
    class TitleCompletion < Engine
      Registry.register(self)

      BASE_WEIGHT = 10

      def self.weight
        BASE_WEIGHT
      end

      def completions
        Suggestions::Suggestion.new(entries: solr_service.terms, engine_weight: self.class.weight)
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      def solr_service
        @solr_service ||= Suggestions::Solr::Service.new(url: Settings.suggester.suggestions.digital_catalog.solr.url,
                                                         query: query)
      end
    end
  end
end
