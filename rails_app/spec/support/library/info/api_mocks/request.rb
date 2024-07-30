# frozen_string_literal: true

module Library
  module Info
    module ApiMocks
      # Webmock stubs when requesting library data from the library website
      module Request
        # @param library_code [String]
        # @param response_body [Hash]
        # @return [WebMock::RequestStub]
        def stub_library_info_api_request_success(library_code:, response_body:)
          stub_request(:get, "#{Settings.library.info.base_url}/#{library_code}")
            .with(headers: default_headers)
            .to_return_json(status: 200, body: response_body)
        end

        # @param library_code [String]
        # @param response_body [Hash]
        # @return [WebMock::RequestStub]
        def stub_library_info_api_request_failure(library_code:, response_body:)
          stub_request(:get, "#{Settings.library.info.base_url}/#{library_code}")
            .with(headers: default_headers)
            .to_return_json(status: 400, body: response_body)
        end

        private

        # @return [Hash]
        def default_headers
          { 'Accept' => '*/*' }
        end

        # @return [Hash]
        def json_headers
          { 'Content-Type' => 'application/json' }
        end
      end
    end
  end
end
