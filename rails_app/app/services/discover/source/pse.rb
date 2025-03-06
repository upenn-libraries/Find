# frozen_string_literal: true

module Discover
  class Source
    # Class representing Google PSE as a data source - PSE JSON API
    class PSE < Source
      attr_reader :source

      def initialize(source:)
        raise ArgumentError, "PSE source #{source} not supported" unless source.to_sym.in?(Configuration::PSE::SOURCES)

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
      rescue StandardError => _e
        # TODO: send redacted honeybadger notification
        # return results with no entries
        Results.new(entries: [], source: self, total_count: 0, results_url: '')
      end

      # @return [Boolean]
      def blacklight?
        false
      end

      # @return [Boolean]
      def pse?
        true
      end

      # @return [Boolean]
      def database?
        false
      end

      private

      # @param [String] query
      # @return [String]
      def results_url(query:)
        I18n.t("discover.links.all_results.#{source}", query: query)
      end

      # @param [Hash] response
      # @return [Integer]
      def total_count(response:)
        response.dig(*Discover::Configuration::PSE::TOTAL_COUNT).to_i
      end

      # @param [Hash] record
      # @return [Hash{Symbol->String, nil}]
      def body_from(record:)
        { description: Array.wrap(record.fetch('snippet')) }
      end

      # @param data [Array]
      # @return [Array<Discover::Entry>]
      def entries_from(data:)
        Array.wrap(data).filter_map do |item|
          Entry.new(title: Array.wrap(item.fetch('title')),
                    body: body_from(record: item), # author, collection, format, location w/ call num?
                    identifiers: config_class::IDENTIFIERS,
                    link_url: item.fetch('link'),
                    thumbnail_url: item.dig('pagemap', 'cse_thumbnail')&.first&.fetch('src'))
        rescue StandardError => e
          Honeybadger.notify(e)

          next
        end
      end

      # Logic for getting at result data from response
      # @param response [Faraday::Response]
      def records_from(response:)
        records = response.dig(*config_class::RECORDS)

        unless records.is_a?(Array)
          raise Error, "Malformed PSE source #{source} json response. Expected an array but got #{records.class}"
        end

        records
      end

      def query_uri(query:)
        query_params = { cx: config_class::CX, key: Discover::Configuration::PSE::KEY, q: query }
        URI::HTTPS.build(host: Discover::Configuration::PSE::HOST,
                         path: Discover::Configuration::PSE::PATH,
                         query: URI.encode_www_form(query_params))
      end
    end
  end
end
