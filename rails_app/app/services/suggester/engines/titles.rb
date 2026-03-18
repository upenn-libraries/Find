# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests title completions and bestbet actions from a solr suggestions endpoint
    class Titles < Engine
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

      # Return completions from the suggester dictionary of all titles
      def completions
        Suggestions::Suggestion.new(
          entries: solr_service.terms(dictionary: completions_dictionary),
          engine_weight: COMPLETION_WEIGHT
        )
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      # Return actions that link to specific "best bet" records from the dictionary of best bet data
      def actions
        Suggestions::Suggestion.new(
          entries: actions_from(solr_service.suggestions[actions_dictionary]),
          engine_weight: ACTION_WEIGHT
        )
      rescue Suggestions::Solr::Service::Error => _e
        super
      end

      private

      # Parse suggester data from Solr service response, including encoded JSON payload. Skip over any suggestions
      # with malformed JSON payloads. Return Action objects.
      # @param suggestions [Array<Hash>]
      # @return [Array<Suggester::Engines::Engine::Action>]
      def actions_from(suggestions)
        suggestions.filter_map do |suggestion|
          parsed_payload = JSON.parse suggestion['payload']
          Action.new label: parsed_payload['disp'],
                     url: Rails.application.routes.url_helpers.solr_document_path(id: parsed_payload['id'])
        rescue JSON::ParserError => _e
          Honeybadger.notify "Malformed JSON in suggester payload: #{suggestion['payload']}"
          next
        end
      end

      def completions_dictionary
        Settings.suggester.digital_catalog.solr.dictionaries.title.completions.to_sym
      end

      def actions_dictionary
        Settings.suggester.digital_catalog.solr.dictionaries.title.actions.to_sym
      end

      # @param query [String]
      def default_solr_service(query)
        Suggestions::Solr::Service.new(url: Settings.suggester.digital_catalog.solr.url, query: query)
      end
    end
  end
end
