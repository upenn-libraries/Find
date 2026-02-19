# frozen_string_literal: true

module Discover
  module ApiMocks
    module Harvester
      module PennMuseum
        # @param body [String] contents to download
        # @param status [Integer] response http status
        # @param response_headers [Hash] response headers
        def stub_csv_download_response(body:, status:, response_headers:)
          host = Settings.discover.source.penn_museum.host
          path = Settings.discover.source.penn_museum.csv.path
          stub_request(:get, URI::HTTPS.build(host: host, path: path))
            .to_return_json(status: status, body: body, headers: response_headers)
        end
      end
    end
  end
end
