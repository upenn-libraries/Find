# frozen_string_literal: true

module Embeddings
  # Make requests to ollama server
  class OllamaClient
    attr_reader :model

    URL = URI::HTTP.build(host: 'localhost', port: 11_434)
    EMBEDDINGS_PATH = '/api/embed'
    DEFAULT_MODEL = 'all-minilm'
    EMBEDDINGS_KEY = 'embeddings'

    def initialize(model: DEFAULT_MODEL)
      @model = model
    end

    def embeddings_for(input:)
      response_body(input: input)[EMBEDDINGS_KEY]
    end

    private

    def response_body(input:)
      request(input: input).body
    end

    def request(input:)
      connection.post(EMBEDDINGS_PATH, { input: input, model: model }.to_json)
    end

    def connection
      @connection ||= Faraday.new(url: URL) do |config|
        config.request :json
        config.response :json
      end
    end
  end
end
