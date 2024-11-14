# frozen_string_literal: true

module Hathi
  module ApiMocks
    module Request
      def stub_single_id_request(request_url:, response_body:)
        stub_request(:get, request_url)
          .to_return_json(status: 200, body: response_body)
      end
    end
  end
end
