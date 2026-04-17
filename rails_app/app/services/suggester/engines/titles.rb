# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions and bestbet actions from a solr suggestions endpoint
    class Titles < Engine
      Registry.register(self)

      BASE_COMPLETIONS_WEIGHT = 10
      MINIMUM_CHARS_REQUIRED = 3

      def self.suggest?(query)
        query.length >= MINIMUM_CHARS_REQUIRED
      end

      attr_reader :solr_service

      def initialize(query:, context: {}, solr_service: default_solr_service(query))
        super(query: query, context: context)
        @solr_service = solr_service
      end

      # Return completions from the suggester for all titles
      def completions
        Suggestions::Suggestion.new(
          entries: solr_service.terms(suggester: completions_suggester_name),
          engine_weight: self.class.completions_weight
        )
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      def completions_suggester_name
        Settings.suggester.digital_catalog.solr.suggesters.title.completions.to_sym
      end

      # @param query [String]
      def default_solr_service(query)
        Suggestions::Solr::Service.new(url: Settings.suggester.digital_catalog.solr.url, query: query)
      end
    end
  end
end
