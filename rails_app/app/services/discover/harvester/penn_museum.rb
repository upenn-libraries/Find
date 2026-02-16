# frozen_string_literal: true

module Discover
  module Harvester
    # Downloads and exposes Penn Museum CSV
    class PennMuseum
      class Error < StandardError; end

      FILENAME = 'penn_museum_artifacts'
      EXTENSION = '.csv'

      # @param connection [Connection]
      # @param headers [Harvest]
      def initialize(connection: Connection.new, headers: default_headers)
        @connection = connection
        @headers = headers
      end

      # @raise [ArgumentError] if no block provided to handle downloaded file
      # @return [Response]
      def download(&block)
        raise_error(I18n.t('discover.harvesters.penn_museum.errors.argument')) if block.nil?

        harvest_response, tempfile = stream_csv

        yield tempfile if harvest_response.success? && tempfile

        harvest_response
      ensure
        cleanup!(tempfile)
      end

      private

      # An array containing the Response object and the downloaded Tempfile or Nil if the response does not have 2xx
      # status code.
      # @return [Array(Response, Tempfile | nil)]
      def stream_csv
        tempfile = nil
        faraday_response = @connection.get(csv_path, headers: @headers) do |req|
          req.options.on_data = proc do |chunk, _overall_received_bytes, env|
            # Do not create empty TempFile when resource has not been modified
            next if Response.not_modified?(env.status)

            tempfile ||= Tempfile.new([FILENAME, EXTENSION], binmode: true)
            tempfile.write chunk
          end
        end
        tempfile&.rewind
        [Response.new(response: faraday_response), tempfile]
      rescue StandardError => e
        handle_error!(tempfile, I18n.t('discover.harvesters.penn_museum.errors.download', error: e))
      end

      # @return [String]
      def csv_path
        Settings.discover.source.penn_museum.csv.path
      end

      # @return [Hash]
      def default_headers
        Harvest.find_or_initialize_by(source: 'penn_museum').headers
      end

      # @param message [String]
      # @raise Discover::Harvester::PennMuseum::Error
      def raise_error(message)
        raise Error, message
      end

      # @param tempfile [Tempfile]
      # @return [Boolean]
      def cleanup!(tempfile)
        tempfile&.close!
      end

      # @raise Discover::Harvester::PennMuseum::Error
      # @param  tempfile [Tempfile]
      # @param message [String]
      def handle_error!(tempfile, message)
        cleanup!(tempfile)
        raise_error(message)
      end
    end
  end
end
