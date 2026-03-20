# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Provides interface for interacting with Solr suggestion json response
      class Response
        JSON_SUGGEST_FIELD = 'suggest'
        JSON_SUGGESTIONS_FIELD = 'suggestions'
        JSON_TERM_FIELD = 'term'

        attr_reader :query, :body

        # @param body [Hash]
        # @param query [Object]
        def initialize(body:, query:)
          @body = body
          @query = query
        end

        # Returns an array of suggestion terms for a given suggester in the response - or all terms if no suggester
        # name is provided.
        # @param suggester [String, Symbol, nil]
        # @return [Array]
        def terms(suggester: nil)
          hash = suggester ? suggestions.slice(suggester.to_sym) : suggestions

          hash.values.flatten.map { |suggestion| suggestion[JSON_TERM_FIELD] }
        end

        # Simplify the suggestions data returned by Solr, keeping top-level keys corresponding to
        # the suggester names.
        # @return [Hash]
        def suggestions
          @suggestions ||= begin
            return {} unless body

            body.fetch(JSON_SUGGEST_FIELD, {}).transform_values { |values|
              values.dig(query, JSON_SUGGESTIONS_FIELD)
            }.symbolize_keys
          end
        end
      end
    end
  end
end
