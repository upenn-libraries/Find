# frozen_string_literal: true

module Discover
  module Harvester
    # Downloads and exposes Penn Museum CSV
    class PennMuseum
      FILENAME = 'penn_museum_artifacts'
      EXTENSION = '.csv'

      # @param  downloader [Discover::Harvester::Downloader]
      def initialize(downloader: Harvester::Downloader.new(connection: Connection.new(base_url: host)))
        @downloader = downloader
      end

      # @raise [ArgumentError] if no block provided to handle downloaded file
      # @return [Response]
      def harvest(headers: default_headers, &block)
        raise ArgumentError, I18n.t('discover.harvesters.penn_museum.errors.argument') if block.nil?

        faraday_response, tempfile = @downloader.download(path: csv_path,
                                                          headers: headers,
                                                          filename: FILENAME,
                                                          extension: EXTENSION)

        harvest_response = Response.new(response: faraday_response)

        yield tempfile if harvest_response.success? && tempfile

        harvest_response
      ensure
        tempfile&.close!
      end

      private

      # @return [String]
      def csv_path
        Settings.discover.source.penn_museum.csv.path
      end

      def host
        URI::HTTPS.build(host: Settings.discover.source.penn_museum.host)
      end

      # @return [Hash]
      def default_headers
        Harvest.find_or_initialize_by(source: 'penn_museum').headers
      end
    end
  end
end
