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

      attr_reader :config

      def initialize(query:, context: {}, config: Settings.suggestions.digital_catalog.solr)
        super(query: query, context: context)
        @config = config
      end

      def completions
        Suggestions::Suggestion.new(entries: solr_service.completions, engine_weight: self.class.weight)
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      def solr_service
        @solr_service ||= Suggestions::Solr::Service.new(url: solr_url, params: { q:  query }, config: config)
      end

      def solr_url
        URI::HTTP.build({ scheme: config.scheme, host: config.host, path: config.path }).to_s
      end
    end
  end
end
