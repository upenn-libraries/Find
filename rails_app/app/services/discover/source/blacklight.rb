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
      rescue StandardError => e
        Honeybadger.notify(e)
        # return results with no entries
        Results.new(entries: [], source: self, total_count: 0, results_url: '')
      end

      # @return [Boolean]
      def blacklight?
        true
      end

      # @return [Boolean]
      def pse?
        false
      end

      # @return [Boolean]
      def database?
        false
      end

      private

      # @param response [Hash]
      # @return [Integer]
      def total_count(response:)
        response.dig(*config_class::TOTAL_COUNT).to_i
      end

      # @param response [Hash]
      # @return [String]
      def results_url(response:)
        return unless config_class::LINK_TO_SOURCE

        uri = URI response.dig(*config_class::RESULTS_URL)
        uri.path = '/'
        uri.to_s
      end

      # TODO: need to add "collection"(?)
      # @param record [Hash]
      # @return [Hash{Symbol->Array, nil}]
      def body_from(record:)
        { creator: json_extract(record: record, keys: config_class::CREATOR),
          format: json_extract(record: record, keys: config_class::FORMAT),
          location: json_extract(record: record, keys: config_class::LOCATION),
          publication: json_extract(record: record, keys: config_class::PUBLICATION),
          description: json_extract(record: record, keys: config_class::DESCRIPTION) }
      end

      # @param record [Hash]
      # @return [Hash]
      def identifiers(record:)
        config_class::IDENTIFIERS.transform_values { |value| record.dig(*value) }
      end

      # Extract ARK values from any Colenda record links to be found in an XML source available for the record
      # @param record [Hash]
      # @return [Array]
      def colenda_arks(record:)
        xml = record.dig(*config_class::XML)&.first
        Array.wrap xml&.match(config_class::COLENDA_LINK_ARK_REGEX)&.captures
      end

      # Generate a thumbnail URL using the Bulwark (Colenda) thumbnail-by-ARK route
      # @param record [Hash]
      # @return [nil, String]
      def colenda_thumbnail_url(record:)
        arks = colenda_arks(record: record)
        return nil if arks.blank?

        "https://colenda.library.upenn.edu/items/ark:/#{arks.first.tr('-', '/')}/thumbnail"
      end

      # Extract entries from response data, mapping response fields to a structure the view can consistently render
      # @param data [Array]
      # @return [Array<Discover::Entry>]
      def entries_from(data:)
        data.filter_map do |record|
          Entry.new(title: json_extract(record: record, keys: config_class::TITLE),
                    body: body_from(record: record),
                    identifiers: identifiers(record: record),
                    link_url: record.dig(*config_class::RECORD_URL),
                    thumbnail_url: colenda_thumbnail_url(record: record))
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
          raise Error, "Malformed Blacklight source #{source} json response. Expected an array but got #{records.class}"
        end

        records
      end

      # @param query [String]
      # @return [URI::Generic]
      def query_uri(query:)
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

      # Safely extract from record hash using provided keys, then ensuring that encoded chars are un-encoded
      # @param record [Hash]
      # @param keys [Array]
      # @return [Array]
      def json_extract(record:, keys:)
        return [] if record.blank? || keys.blank?

        Array.wrap(record.dig(*keys))&.map { |v| CGI.unescapeHTML v } || []
      end
    end
  end
end
