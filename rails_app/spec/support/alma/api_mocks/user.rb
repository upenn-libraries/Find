# frozen_string_literal: true

module Alma
  module ApiMocks
    module User
      # @param [String] id
      # @param [Hash] response_body
      # @return [WebMock::RequestStub]
      def stub_alma_user_find_success(id:, response_body:)
        stub_request(:get, "#{Alma::User.users_base_path}/#{id}?expand=fees,requests,loans")
          .to_return_json(status: 200, body: response_body, headers: {})
      end
    end
  end
end
