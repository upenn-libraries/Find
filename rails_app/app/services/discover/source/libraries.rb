# frozen_string_literal: true

module Discover
  class Source
    # Class representing the "libraries" as a data source - aka Find JSON API
    class Libraries < Source
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
      def body_from(record:)
        { author: record.dig('attributes', 'creator_ss', 'attributes', 'value'),
          format: record.dig('attributes', 'format_facet', 'attributes', 'value') }
      end

      # Perhaps this is best done in a ViewComponent? The mapping from response data to Entry is Source-specific, so
      # it seems to belong here - otherwise we need "Entry" components per-Source
      def entries_from(data:)
        data.filter_map do |record|
          Entry.new(title: record.dig('attributes', 'title'),
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
        # TODO: do these need to be inclusive? if we do exclusive, the first facet will limit the following facets
        # (specifically for the library facet, do we want to be able to include two library facets and get all results?)
        query_params = { 'f[access_facet][]': Configuration::Libraries::ACCESS_VALUES,
                         'f[library_facet][]': Configuration::Libraries::LIBRARY_VALUES,
                         search_field: 'all_fields', q: query }
        URI::HTTPS.build(host: Configuration::Libraries::HOST,
                         path: Configuration::Libraries::PATH,
                         query: URI.encode_www_form(query_params))
      end
    end
  end
end
