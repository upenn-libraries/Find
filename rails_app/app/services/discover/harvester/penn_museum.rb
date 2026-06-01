# frozen_string_literal: true

module Discover
  module Harvester
    # Downloads and exposes Penn Museum CSV
    #
    # Collapsed from the earlier Connection + Downloader + Response abstractions
    # which were speculative generality — we only ever harvest from Penn Museum.
    class PennMuseum
      class Error < StandardError; end

      NOT_MODIFIED = 304

      # Lightweight value object replacing Discover::Harvester::Response
      # to avoid a one-use wrapper class.
      HarvestResult = Struct.new(:faraday_response, keyword_init: true) do
        # @return [Boolean]
        def success?
          faraday_response.success?
        end

        # @return [Hash]
        def headers
          {
            'last-modified' => faraday_response.headers['last-modified'],
            'etag' => faraday_response.headers['etag']
          }
        end
      end

      # @return [PennMuseum]
      def initialize
        @connection = build_connection
      end

      # Downloads and yields the Penn Museum CSV to the caller.
      #
      # @param headers [Hash] request headers (defaults to stored harvest headers)
      # @yield [Tempfile | nil] the downloaded CSV, rewound and ready to read
      # @return [HarvestResult]
      # @raise [Error] if no block given
      def harvest(headers: default_headers, &block)
        raise Error, 'A block is required to handle downloaded file.' if block.nil?

        tempfile = nil
        faraday_response = @connection.get(csv_path, nil, headers) do |req|
          req.options.on_data = proc do |chunk, _overall_received_bytes, env|
            next if env.status == NOT_MODIFIED

            tempfile ||= Tempfile.new([filename, extension], binmode: true)
            tempfile.write chunk
          end
        end

        tempfile&.rewind

        harvest_result = HarvestResult.new(faraday_response: faraday_response)

        yield tempfile if harvest_result.success? && tempfile

        harvest_result
      rescue StandardError => e
        tempfile&.close!
        raise e
      ensure
        tempfile&.close!
      end

      private

      # @return [Faraday::Connection]
      def build_connection
        Faraday.new(host, headers: { 'User-Agent': Configuration::USER_AGENT }) do |conn|
          conn.response :raise_error
        end
      end

      # @return [String]
      def csv_path
        Settings.discover.source.penn_museum.csv.path
      end

      # @return [String]
      def filename
        Settings.discover.source.penn_museum.csv.download.filename
      end

      # @return [String]
      def extension
        Settings.discover.source.penn_museum.csv.download.extension
      end

      # @return [URI::Generic]
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
