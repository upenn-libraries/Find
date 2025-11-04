# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Provides interface for interacting with Solr suggestion json response
      class Response
        JSON_SUGGESTIONS_FIELD = 'suggestions'

        attr_reader :handler, :dictionary, :query, :body

        def initialize(response:, handler:, dictionary:, query:)
          @body = response.body
          @handler = handler
          @dictionary = dictionary
          @query = query
        end

        def completions
          data.map { |suggestion| suggestion['term'] }
        end

        def data
          body.dig(handler, dictionary, query, JSON_SUGGESTIONS_FIELD)
        end

        def count
          completions.size
        end
      end
    end
  end
end
