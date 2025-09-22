# frozen_string_literal: true

module Catalog
  # Returns suggested facet searches based on a query
  class SuggestionsComponent < Blacklight::Component
    LIMIT = 3

    attr_reader :query, :suggester, :record

    def initialize(query:, record: Subject, suggester: Embeddings::Service)
      @query = query
      @record = record
      @suggester = suggester.new(input: @query)
    end

    def render?
      suggestions.any?
    end

    def suggestions
      nearest_neighbors.first(LIMIT)
    end

    private

    def facet
      "f[#{record.to_s.downcase}_facet][]"
    end

    def nearest_neighbors
      @nearest_neighbors ||= record.nearest_neighbors(:embedding, embedding.vector, distance: 'euclidean')
    end

    def embedding
      @embedding ||= suggester.first_embedding
    end
  end
end
