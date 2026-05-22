# frozen_string_literal: true

module Hathi
  module ApiMocks
    module Request
      def stub_empty_hathi_request
        stub_request(:get, %r{^#{Regexp.escape(Settings.hathi.base_url)}/.*})
          .to_return do |request|
            identifier = request.uri.to_s.split('/').last

            { status: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: { identifier.to_s => { 'records' => [], 'items' => [] } }.to_json }
          end
      end

      def stub_present_hathi_request(response:)
        stub_request(:get, %r{^#{Regexp.escape(Settings.hathi.base_url)}/.*})
          .to_return do |request|
            identifier = request.uri.to_s.split('/').last

            { status: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: { identifier.to_s => response }.to_json }
          end
      end
    end
  end
end
