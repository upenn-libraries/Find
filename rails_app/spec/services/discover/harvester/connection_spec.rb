# frozen_string_literal: true

describe Discover::Harvester::Connection do
  let(:connection) { described_class.new(base_url: base_url) }
  let(:base_url) { 'https://www.example.com' }

  describe '#get' do
    let(:path) { '/test' }
    let(:headers) { { 'If-None-Match' => '123456' } }
    let(:response) { connection.get(path, headers: headers) }

    before do
      stub_request(:get, URI::HTTPS.build(host: 'www.example.com', path: path)).and_return(status: 200, body: '')
    end

    it 'returns a faraday response' do
      expect(response).to be_a Faraday::Response
    end

    it 'uses request default headers' do
      request_headers = response.env.request_headers
      expect(request_headers).to include('User-Agent': Discover::Configuration::USER_AGENT)
    end

    it 'applies submitted headers' do
      request_headers = response.env.request_headers
      expect(request_headers).to include(headers)
    end

    it 'applies block logic to the connection' do
      response = connection.get(path) do |request|
        request.headers = { test: 'test' }
      end
      expect(response.env.request_headers).to include(test: 'test')
    end

    context 'with an unsuccessful request' do
      before do
        stub_request(:get, URI::HTTPS.build(host: 'www.example.com', path: path)).and_return(status: 500, body: '')
      end

      it 'raises an error' do
        expect { response }.to raise_error(Faraday::Error)
      end
    end
  end
end
