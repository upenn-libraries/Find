# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions and bestbet actions from a solr suggestions endpoint
    class Title < Engine
      Registry.register(self)

      COMPLETION_WEIGHT = 10
      ACTION_WEIGHT = 25
      MINIMUM_CHARS_REQUIRED = 3

      def self.suggest?(query)
        query.length >= MINIMUM_CHARS_REQUIRED
      end

      attr_reader :solr_service

      def initialize(query:, context: {}, solr_service: default_solr_service(query))
        super(query: query, context: context)
        @solr_service = solr_service
      end

      def completions
        Suggestions::Suggestion.new(
          entries: solr_service.terms(dictionary: completions_dictionary),
          engine_weight: COMPLETION_WEIGHT
        )
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      def actions
        Suggestions::Suggestion.new(
          entries: action_entries(solr_service.suggestions[actions_dictionary]),
          engine_weight: ACTION_WEIGHT
        )
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      def action_entries(terms)
        terms.filter_map do |term|
          data = JSON.parse(term['payload'])
          { label: data['disp'], url: Rails.application.routes.url_helpers.solr_document_path(id: data['id']) }
        rescue JSON::ParserError => _e # malformed payload
          next
        end
      end

      def completions_dictionary
        Settings.suggester.digital_catalog.solr.dictionaries.completions
      end

      def actions_dictionary
        Settings.suggester.digital_catalog.solr.dictionaries.actions
      end

      def default_solr_service(query)
        Suggestions::Solr::Service.new(url: Settings.suggester.digital_catalog.solr.url, query: query)
      end
    end
  end
end
