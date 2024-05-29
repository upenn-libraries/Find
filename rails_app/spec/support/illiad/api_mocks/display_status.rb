# frozen_string_literal: true

module Illiad
  module ApiMocks
    # Webmock stubs when requesting Illiad Api DisplayStatus resources
    module DisplayStatus
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_display_status_find_all_success(response_body:)
        stub_request(:get, "#{Settings.illiad.base_url}/#{Illiad::DisplayStatus::BASE_PATH}")
          .with(headers: default_headers)
          .to_return(status: 200, body: response_body)
      end

      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_display_status_find_all_failure(response_body:)
        stub_request(:get, "#{Settings.illiad.base_url}/#{Illiad::DisplayStatus::BASE_PATH}")
          .with(headers: default_headers)
          .to_return_json(status: 401, body: response_body)
      end

      private

      def default_headers
        { 'Accept' => '*/*' }
      end
    end
  end
end
