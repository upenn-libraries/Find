# frozen_string_literal: true

module Discover
  module Harvester
    # Streams external resource to a Tempfile
    class Downloader
      # @param connection [Discover::Harvester::Connection]
      def initialize(connection:)
        @connection = connection
      end

      # An array containing the Faraday response object and the downloaded Tempfile or Nil if the response does not have
      # 2xx status code.
      # @param [String] path
      # @param [String] filename
      # @param [String] extension
      # @param [Hash] headers
      # @return [Array(Faraday::Response, Tempfile | nil)]
      def download(path:, filename:, extension:, headers: {})
        tempfile = nil
        response = @connection.get(path, headers: headers) do |req|
          req.options.on_data = proc do |chunk, _overall_received_bytes, env|
            # Do not create empty TempFile when resource has not been modified
            next if Response.not_modified?(env.status)

            tempfile ||= Tempfile.new([filename, extension], binmode: true)
            tempfile.write chunk
          end
        end
        tempfile&.rewind
        [response, tempfile]
      rescue StandardError => e
        tempfile&.close!
        raise e
      end
    end
  end
end
