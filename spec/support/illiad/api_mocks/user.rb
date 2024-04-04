# frozen_string_literal: true

module Illiad
  module ApiMocks
    # Webmock stubs when requesting Illiad Api User resource
    module User
      # @param id [Integer, String] Illiad username
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_find_user_success(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::User::BASE_PATH}/#{id}")
          .with(headers: default_headers)
          .to_return_json(status: 200, body: response_body)
      end

      # @param id [Integer, String] Illiad username
      # @param response_body [Hash]
      # # @return [WebMock::RequestStub]
      def stub_find_user_failure(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::User::BASE_PATH}/#{id}")
          .with(headers: default_headers)
          .to_return_json(status: 404, body: response_body)
      end

      # @param request_body [Hash]
      # @param response_body [Hash]
      # # @return [WebMock::RequestStub]
      def stub_create_user_success(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::User::BASE_PATH}")
          .with(body: request_body, headers: json_headers)
          .to_return_json(status: 200, body: response_body)
      end

      # @param request_body [Hash]
      # @param response_body [Hash]
      # # @return [WebMock::RequestStub]
      def stub_create_user_failure(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::User::BASE_PATH}")
          .with(body: request_body, headers: json_headers)
          .to_return_json(status: 401, body: response_body)
      end

      # @param user_id [Integer, String]
      # @param response_body [Hash]
      # @param options [Hash]
      # # @return [WebMock::RequestStub]
      def stub_user_requests_success(user_id:, response_body:, **options)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::User::USER_REQUESTS_BASE_PATH}/#{user_id}")
          .with(query: options, headers: default_headers)
          .to_return(status: 200, body: response_body)
      end

      # @param user_id [Integer, String]
      # @param response_body [Hash]
      # @param options [Hash]
      # # @return [WebMock::RequestStub]
      def stub_user_requests_failure(user_id:, response_body:, **options)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::User::USER_REQUESTS_BASE_PATH}/#{user_id}")
          .with(query: options, headers: default_headers)
          .to_return_json(status: 401, body: response_body)
      end

      private

      def default_headers
        { 'Accept' => '*/*' }
      end

      def json_headers
        { 'Content-Type' => 'application/json' }
      end
    end
  end
end
