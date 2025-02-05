# frozen_string_literal: true

module Discover
  class Source
    # Class representing the "libraries" as a data source - aka Find JSON API
    class Blacklight < Source
      attr_accessor :type

      def initialize(type:)
        unless type.to_sym.in?(Configuration::Blacklight::SOURCES)
          raise ArgumentError, "Blacklight type #{type} not supported"
        end

        @type = type
      end

      # @param query [String]
      def results(query:)
        request_url = query_uri query: query
        connection = connection(base_url: request_url.host)
        response = connection.get(request_url).body
        data = records_from(response: response)
        Results.new(entries: entries_from(data: data), source: self)
      rescue Faraday::Error => _e
        # TODO: something nice
      end

      private

      # TODO: need to add "collection"(?) & location to CatalogController JSON response
      # @param [Hash] record
      # @return [Hash{Symbol->String, nil}]
      def body_from(record:)
        { author: record.dig('attributes', config_class::AUTHOR_FIELD, 'attributes', 'value'),
          format: record.dig('attributes', config_class::FORMAT_FIELD, 'attributes', 'value') }
      end

      # Perhaps this is best done in a ViewComponent? The mapping from response data to Entry is Source-specific, so
      # it seems to belong here - otherwise we need "Entry" components per-Source
      # @param [Hash] data
      # @return [Array]
      def entries_from(data:)
        data.filter_map do |record|
          Entry.new(title: record.dig('attributes', config_class::TITLE_FIELD),
                    subtitle: nil, # could use depending on design TODO: do we need subtitle? extract it?
                    body: body_from(record: record), # author, collection, format, location w/ call num?
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
        @config_class ||= "Discover::Configuration::Blacklight::#{type.camelize}".constantize
      end
    end
  end
end
