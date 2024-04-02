# frozen_string_literal: true

module Illiad
  module ApiMocks
    # Webmock stubs when requesting Illiad Api Transaction Request resources
    module Request
      # @param request_body [Hash]
      # @param response_body [Hash]
      # # @return [WebMock::RequestStub]
      def stub_submit_request_success(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}")
          .with(body: request_body, headers: json_headers)
          .to_return_json(status: 200, body: response_body)
      end

      # @param request_body [Hash]
      # @param response_body [Hash]
      # # @return [WebMock::RequestStub]
      def stub_submit_request_failure(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}")
          .with(body: request_body, headers: json_headers)
          .to_return_json(status: 400, body: response_body)
      end

      # @param id [Integer, String] request TransactionNumber
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_find_request_success(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}")
          .with(headers: default_headers)
          .to_return_json(status: 200, body: response_body)
      end

      # @param id [Integer, String] request TransactionNumber
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_find_request_failure(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}")
          .with(headers: default_headers)
          .to_return_json(status: 404, body: response_body)
      end

      # @param id [Integer, String] request TransactionNumber
      # @param note [String] note to send in body
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_add_note_success(id:, note:, response_body:)
        stub_request(:post,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::NOTES_PATH}")
          .with(body: { Note: note }, headers: json_headers)
          .to_return_json(status: 200, body: response_body)
      end

      # @param id [Integer, String] request TransactionNumber
      # @param note [String] note to send in body
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_add_note_failure(id:, note:, response_body:)
        stub_request(:post,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::NOTES_PATH}")
          .with(body: { Note: note }, headers: json_headers)
          .to_return_json(status: 400, body: response_body)
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
