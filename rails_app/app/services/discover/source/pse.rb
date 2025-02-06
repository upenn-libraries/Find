# frozen_string_literal: true

module Discover
  class Source
    # Class representing Google PSE as a data source - PSE JSON API
    class PSE < Source
      attr_reader :source

      def initialize(source:)
        @source = source
      end

      def results(query:)
        request_url = query_uri query: query
        connection = connection(base_url: request_url.host)
        response = connection.get(request_url).body
        # use the response to get total count and all results url
        data = records_from(response: response)
        Results.new(entries: entries_from(data: data), source: self,
                    total_count: total_count(response: response),
                    results_url: results_url(query: query))
      end

      private

      # @param [String] query
      # @return [String]
      def results_url(query:)
        I18n.t("urls.discover.all_results.#{source}", query: query)
      end

      # @param [Hash] response
      # @return [Integer]
      def total_count(response:)
        response['searchInformation']['totalResults']&.to_i
      end

      # @param [Hash] record
      # @return [Hash{Symbol->String, nil}]
      def body_from(record:)
        { snippet: record.fetch('snippet') }
      end

      def entries_from(data:)
        Array.wrap(data).filter_map do |item|
          Entry.new(title: item.fetch('title').split('|').first,
                    body: body_from(record: item), # author, collection, format, location w/ call num?
                    link_url: item.fetch('link'),
                    thumbnail_url: item.dig('pagemap', 'cse_thumbnail')&.first&.fetch('src'))
        rescue StandardError => _e
          # TODO: log an issue parsing a record

          next
        end
      end

      # Logic for getting at result data from response
      # @param response [Faraday::Response]
      def records_from(response:)
        response['items']
      end

      def query_uri(query:)
        query_params = { cx: config_class::CX, key: Discover::Configuration::PSE::KEY, q: query }
        URI::HTTPS.build(host: Discover::Configuration::PSE::HOST,
                         path: Discover::Configuration::PSE::PATH,
                         query: URI.encode_www_form(query_params))
      end

      # @return [Object]
      def config_class
        @config_class ||= "Discover::Configuration::PSE::#{source.camelize}".safe_constantize
      end
    end
  end
end
