# frozen_string_literal: true

module Embeddings
  # Orchestrate retrieving embeddings from a LLM
  class Service
    attr_reader :input, :client, :parser

    def initialize(input:, client: OllamaClient.new)
      @client = client
      @input = input
    end

    def first_embedding
      embeddings.first
    end

    def embeddings
      @embeddings ||= Embeddings.all(input: input, embeddings: client.embeddings_for(input: input))
    end

    def commit(record: Subject)
      embeddings.each do |embedding|
        record.find_or_create_by(content: embedding.content).update(embedding: embedding.vector)
      end
    end
  end
end
