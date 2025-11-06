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

        # @return [Array<String>]
        def terms
          suggestions.values.flatten.map { |suggestion| suggestion[JSON_TERM_FIELD] }
        end

        # @return [Hash<Array>]
        def suggestions
          return {} unless body

          body.fetch(JSON_SUGGEST_FIELD, {}).transform_values do |suggester|
            suggester.dig(query, JSON_SUGGESTIONS_FIELD) || []
          end
        end
      end
    end
  end
end
