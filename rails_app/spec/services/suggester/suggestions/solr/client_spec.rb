# frozen_string_literal: true

describe Suggester::Suggestions::Solr::Client do
  include Suggester::SpecHelpers

  let(:url) { Settings.suggester.digital_catalog.solr.url }
  let(:params) { { "suggest.q": 'art' } }
  let(:client) { described_class.new(url: url, params: params) }

  describe '#initalize' do
    it 'parses url into a URI object' do
      expect(client.uri).to be_a URI
    end
  end

  describe '#response_body' do
    let(:response_body) { json_fixture('response', 'suggester/solr') }
    let(:parsed_response) { JSON.parse(response_body) }

    before do
      stub_solr_suggestions_request(query_params: params, response_body: response_body)
    end

    it 'returns the parsed json response' do
      expect(client.response_body).to eq parsed_response
    end

    context 'with a failed request' do
      before do
        stub_solr_suggestions_request(query_params: params, response_body: {}, status: 500)
        allow(Honeybadger).to receive(:notify)
      end

      it 'raises a Suggester::Suggestions::Solr::Service::Error' do
        expect { client.response_body }.to raise_error(Suggester::Suggestions::Solr::Service::Error)
        expect(Honeybadger).to have_received(:notify).with(Faraday::Error)
      end
    end
  end
end
