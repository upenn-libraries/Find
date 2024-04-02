# frozen_string_literal: true

module Illiad
  module ApiMocks
    # Webmock stubs when requesting Illiad Api Transaction Request resources
    module Request
      def stub_submit_request_success(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}")
          .with(
            body: request_body,
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(status: 200, body: response_body,
                      headers: { 'Content-Type' => 'application/json' })
      end

      def stub_submit_request_failure(request_body:, response_body:)
        stub_request(:post, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}")
          .with(
            body: request_body,
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(
            status: 400,
            body: response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      def stub_find_request_success(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}")
          .with(headers: default_headers)
          .to_return(
            status: 200,
            body: response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      def stub_find_request_failure(id:, response_body:)
        stub_request(:get, "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}")
          .with(
            headers: default_headers
          )
          .to_return(status: 404, body: response_body,
                     headers: { 'Content-Type' => 'application/json' })
      end

      def stub_cancel_request_success(id:, response_body:)
        stub_request(:put,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::ROUTE_PATH}")
          .with(
            body: { Status: Illiad::Request::CANCELLED_BY_USER_STATUS },
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(
            status: 200,
            body: response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      def stub_cancel_request_failure(id:, response_body:)
        stub_request(:put,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::ROUTE_PATH}")
          .with(
            body: { Status: Illiad::Request::CANCELLED_BY_USER_STATUS },
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(
            status: 400,
            body: response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      def stub_add_note_success(id:, note:, response_body:)
        stub_request(:post,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::NOTES_PATH}")
          .with(
            body: { Note: note },
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(status: 200, body: response_body,
                      headers: { 'Content-Type' => 'application/json' })
      end

      def stub_add_note_failure(id:, note:, response_body:)
        stub_request(:post,
                     "#{Settings.illiad_base_url}/#{Illiad::Request::BASE_PATH}/#{id}/#{Illiad::Request::NOTES_PATH}")
          .with(
            body: { Note: note },
            headers: { 'Content-Type' => 'application/json' }
          ).to_return(status: 400, body: response_body,
                      headers: { 'Content-Type' => 'application/json' })
      end

      private

      def default_headers
        { 'Accept' => '*/*' }
      end
    end
  end
end
