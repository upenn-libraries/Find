# frozen_string_literal: true

module Discover
  module ApiMocks
    module Request
      def stub_find_request(query:, response:)
        stub_request(:get, URI::HTTPS.build(host: Discover::Configuration::Blacklight::Find::HOST,
                                            path: Discover::Configuration::Blacklight::Find::PATH,
                                            query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end

      def stub_finding_aids_request(query:, response:)
        stub_request(:get, URI::HTTPS.build(host: Discover::Configuration::Blacklight::FindingAids::HOST,
                                            path: Discover::Configuration::Blacklight::FindingAids::PATH,
                                            query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end
    end
  end
end
