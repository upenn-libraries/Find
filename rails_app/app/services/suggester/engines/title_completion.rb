# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions from a solr suggestions endpoint
    class TitleCompletion < Engine
      Registry.register(self)

      BASE_WEIGHT = 10
      MINIMUM_CHARS_REQUIRED = 3

      def self.weight
        BASE_WEIGHT
      end

      def self.suggest?(query)
        query.length >= MINIMUM_CHARS_REQUIRED
      end

      attr_reader :solr_service

      def initialize(query:, context: {}, solr_service: default_solr_service(query))
        super(query: query, context: context)
        @solr_service = solr_service
      end

      def completions
        Suggestions::Suggestion.new(entries: solr_service.terms, engine_weight: self.class.weight)
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      def default_solr_service(query)
        Suggestions::Solr::Service.new(url: Settings.suggester.digital_catalog.solr.url, query: query)
      end
    end
  end
end
