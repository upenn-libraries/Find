# frozen_string_literal: true

describe Suggester::Suggestions::Solr::Service do
  include Suggester::SpecHelpers
  let(:query) { 'query' }
  let(:service) { described_class.new(query: query, url: Settings.suggester.digital_catalog.solr.url) }

  describe '#params' do
    let(:service) do
      described_class.new(query: query, url: Settings.suggester.digital_catalog.solr.url,
                          dictionary: %w[title author], count: 1, build: true)
    end

    it 'returns configured params' do
      expect(service.params).to eq(
        { "suggest.q": query, "suggest.dictionary": %w[title author],
          "suggest.build": true, "suggest.count": 1 }
      )
    end
  end

  describe '#response' do
    let(:query) { 'art' }
    let(:response_body) { json_fixture('response', 'suggester/solr') }
    let(:parsed_response) { JSON.parse(response_body) }
    let(:params) { { "suggest.q": query } }

    before do
      stub_solr_suggestions_request(query_params: params, response_body: response_body)
    end

    it 'returns a solr response object' do
      expect(service.response).to be_a Suggester::Suggestions::Solr::Response
    end

    it 'constructs the solr response object with the expected values' do
      expect(service.response).to have_attributes(body: parsed_response, query: query)
    end

    context 'with optional params' do
      let(:service) do
        described_class.new(query: query, url: Settings.suggester.digital_catalog.solr.url,
                            dictionary: %w[title author], count: 1, build: true)
      end

      let(:params) do
        { "suggest.q": query, "suggest.dictionary": %w[title author], "suggest.build": true, "suggest.count": 1 }
      end

      it 'constructs the solr response object with the expected values' do
        expect(service.response).to have_attributes(body: parsed_response, query: query)
      end
    end
  end
end
