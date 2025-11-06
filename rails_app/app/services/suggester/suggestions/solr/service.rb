# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Orchestrates requests to solr suggestion endpoint
      class Service
        # Custom error
        class Error < StandardError; end

        attr_reader :url, :query, :dictionary, :count, :build

        # @param url [String]
        # @param query [String]
        # @param dictionary [Array]
        # @param count [Integer, nil]
        # @param build [Boolean, nil]
        def initialize(url:, query:, dictionary: [], count: nil, build: nil)
          @url = url
          @query = query
          @dictionary = Array.wrap dictionary
          @count = count
          @build = build
        end

        delegate :terms, :suggestions, :for_suggester, :suggester, to: :response

        # @return [Suggester::Suggestions::Solr::Response]
        def response
          @response ||= Response.new(body: client.response_body, query: query)
        end

        private

        # @return [Hash]
        def params
          @params ||= {
            "suggest.dictionary": dictionary,
            "suggest.build": build,
            "suggest.q": query,
            "suggest.count": count
          }.compact_blank
        end

        # @return [Suggester::Suggestions::Solr::Client]
        def client
          @client ||= Client.new(url: url, params: params)
        end
      end
    end
  end
end
