# frozen_string_literal: true

module Discover
  class Source
    # Class representing an internal database table as a data source
    class Database < Source
      attr_reader :source

      def initialize(source:)
        unless source.to_sym.in?(Configuration::Database::SOURCES)
          raise ArgumentError,
                "Database source #{source} not supported"
        end

        @source = source
      end

      # @param query [String]
      # @return [Discover::Results]
      def results(query:)
        data = config_class::MODEL.search(query)
        Results.new(records: records_from(data: data),
                    source: self,
                    total_count: data.count,
                    results_url: results_url(query: query))
      rescue StandardError => e
        Honeybadger.notify(e)
        # return results with no entries
        Results.new(records: [], source: self, total_count: 0, results_url: '')
      end

      # @return [Boolean]
      def blacklight?
        false
      end

      # @return [Boolean]
      def pse?
        false
      end

      # @return [Boolean]
      def database?
        true
      end

      private

      # @param [String] query
      # @return [String]
      def results_url(query:)
        I18n.t("discover.links.all_results.#{source}", query: query)
      end

      # @param record [ApplicationRecord]
      # @return [Hash{Symbol->String, nil}]
      def body_from(record:)
        { creator: Array.wrap(record.creator),
          description: Array.wrap(record.description),
          format: Array.wrap(record.format),
          location: Array.wrap(record.location) }
      end

      # @param data [Array<ApplicationRecord>]
      # @return [Array<Discover::Record>]
      def records_from(data:)
        Array.wrap(data).filter_map do |record|
          Record.new(title: Array.wrap(record.title),
                     body: body_from(record: record),
                     identifiers: config_class::IDENTIFIERS,
                     link_url: record.link,
                     thumbnail_url: record.thumbnail_url)
        rescue StandardError => e
          Honeybadger.notify(e)

          next
        end
      end
    end
  end
end
