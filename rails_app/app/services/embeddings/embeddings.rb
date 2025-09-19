# frozen_string_literal: true

module Embeddings
  # Smarter object to conveniently interact with embeddings
  class Embedding
    attr_reader :content, :vector

    def initialize(content:, vector:)
      @content = content
      @vector = vector
    end
  end

  # A collection of Embeddings
  class Embeddings
    def self.all(input:, embeddings:)
      new(input: input, embeddings: embeddings).all
    end

    attr_reader :input, :embeddings

    def initialize(input:, embeddings:)
      @input = Array.wrap input
      @embeddings = embeddings
    end

    def all
      input.zip(embeddings).map { |pair| Embedding.new(content: pair.first, vector: pair.last) }
    end
  end
end
