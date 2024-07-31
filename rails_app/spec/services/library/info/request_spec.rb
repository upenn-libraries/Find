# frozen_string_literal: true

describe Library::Info::Request do
  include Library::Info::ApiMocks::Request

  let(:code) { 'TheLib' }
  let(:response_body) { build(:library_info_api_request_response, :with_all_info) }

  describe '.find' do
    context 'with a successful api request' do
      before { stub_library_info_api_request_success(library_code: code, response_body: response_body) }

      it 'returns a Library::Info::Request object' do
        expect(described_class.find(library_code: code)).to be_a(described_class)
      end
    end

    context 'with an unsuccessful api request' do
      before do
        stub_library_info_api_request_failure(library_code: code, response_body: response_body)
        allow(Honeybadger).to receive(:notify)
      end

      it 'notifies Honeybadger' do
        described_class.find(library_code: code)

        expect(Honeybadger).to have_received(:notify).with(Faraday::Error)
      end

      it 'returns nil' do
        expect(described_class.find(library_code: code)).to be_nil
      end
    end
  end
end
