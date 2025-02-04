# frozen_string_literal: true

module Discover
  module ApiMocks
    module Request
      def stub_libraries_request(query:, response:)
        stub_request(:get, URI::HTTPS.build(host: Discover::Configuration::Libraries::HOST,
                                            path: Discover::Configuration::Libraries::PATH,
                                            query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end
    end
  end
end
