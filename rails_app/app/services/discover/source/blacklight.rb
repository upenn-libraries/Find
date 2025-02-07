# frozen_string_literal: true

module Discover
  class Source
    # Class representing the "libraries" as a data source - aka Find JSON API
    class Blacklight < Source
      attr_accessor :source

      def initialize(source:)
        unless source.to_sym.in?(Configuration::Blacklight::SOURCES)
          raise ArgumentError, "Blacklight source #{source} not supported"
        end

        @source = source
      end

      # @param query [String]
      def results(query:)
        request_url = query_uri query: query
        connection = connection(base_url: request_url.host)
        response = connection.get(request_url).body
        data = records_from(response: response)
        Results.new(entries: entries_from(data: data), source: self,
                    total_count: total_count(response: response),
                    results_url: results_url(response: response))
      rescue Faraday::Error => e
        Honeybadger.notify(e)
        # return results with no entries
        Results.new(entries: [], source: self, total_count: 0, results_url: '')
      end

      private

      # @param [Hash] response
      # @return [Integer]
      def total_count(response:)
        response.dig('meta', 'pages', 'total_count').to_i
      end

      # @param [Hash] response
      # @return [String]
      def results_url(response:)
        uri = URI(response.dig('links', 'self'))
        uri.path = '/'
        uri.to_s
      end

      # TODO: need to add "collection"(?)
      # @param [Hash] record
      # @return [Hash{Symbol->String, nil}]
      def body_from(record:)
        { author: record.dig('attributes', config_class::AUTHOR_FIELD, 'attributes', 'value'),
          format: record.dig('attributes', config_class::FORMAT_FIELD, 'attributes', 'value'),
          location: record.dig('attributes', config_class::LOCATION_FIELD, 'attributes', 'value') }
      end

      # @param [Hash] record
      # @return [Hash]
      def identifiers(record:)
        config_class::IDENTIFIERS.transform_values { |field| record.dig('attributes', field, 'attributes', 'value') }
      end

      # Perhaps this is best done in a ViewComponent? The mapping from response data to Entry is Source-specific, so
      # it seems to belong here - otherwise we need "Entry" components per-Source
      # @param [Hash] data
      # @return [Array]
      def entries_from(data:)
        data.filter_map do |record|
          Entry.new(title: record.dig('attributes', config_class::TITLE_FIELD),
                    body: body_from(record: record), # author, collection, format, location w/ call num?
                    identifiers: identifiers(record: record),
                    link_url: record.dig('links', 'self'),
                    thumbnail_url: 'https://some.books.google.url/') # TODO: get URL from data
        rescue StandardError => _e
          # TODO: log an issue parsing a record
          next
        end
      end

      # Logic for getting at result data from response
      # @param response [Faraday::Response]
      def records_from(response:)
        raise unless response&.key? 'data'

        response['data']
      end

      # @param query [String]
      # @return [URI::Generic]
      def query_uri(query:)
        # (specifically for the library facet, do we want to be able to include two library facets and get all results?)
        query_config = config_class::QUERY_PARAMS
        query_params = query_config.merge({ q: query })
        URI::HTTPS.build(host: config_class::HOST,
                         path: config_class::PATH,
                         query: URI.encode_www_form(query_params))
      end

      # @return [Object]
      def config_class
        @config_class ||= "Discover::Configuration::Blacklight::#{source.camelize}".safe_constantize
      end
    end
  end
end
