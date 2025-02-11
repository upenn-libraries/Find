# frozen_string_literal: true

module Discover
  module ApiMocks
    module Request
      # Can take either 'find' or 'finding_aids' as the 'source' argument
      # @param source [String] either 'find' or 'finding_aids'
      # @param query [String] the user query
      # @param response [string] the simulated json response, read in from a fixture
      def stub_blacklight_response(source:, query:, response:)
        host = "Discover::Configuration::Blacklight::#{source.camelize}::HOST".safe_constantize
        path = "Discover::Configuration::Blacklight::#{source.camelize}::PATH".safe_constantize
        stub_request(:get, URI::HTTPS.build(host: host, path: path, query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end

      def stub_pse_response(query:, response:)
        host = Discover::Configuration::PSE::HOST
        path = Discover::Configuration::PSE::PATH
        stub_request(:get, URI::HTTPS.build(host: host, path: path, query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end
    end
  end
end
