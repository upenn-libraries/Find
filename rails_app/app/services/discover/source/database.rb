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
        Array.wrap(data).filter_map do |db_record|
          Record.new(title: Array.wrap(db_record.title),
                     body: body_from(record: db_record),
                     identifiers: config_class::IDENTIFIERS,
                     link_url: db_record.link,
                     thumbnail: thumbnail_data_from(db_record))
        rescue StandardError => e
          Honeybadger.notify(e)

          next
        end
      end

      # Thumbnail data can be stored in either a thumbnail or thumbnail_url field. The Record doesn't care,
      # but the rendering component will know which to use. This should probably be rethought in the future.
      # @param [ApplicationRecord] db_record
      # @return [String, nil]
      def thumbnail_data_from(db_record)
        db_record.try(:thumbnail) || db_record.try(:thumbnail_url)
      end
    end
  end
end
