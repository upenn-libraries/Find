# frozen_string_literal: true

describe Library::Info::Request do
  include Library::ApiMocks::Request

  let(:library_code) { 'TheLib' }
  let(:response_body) { build(:library_info_request_response, :with_all_info) }

  describe '.find' do
    context 'with a successful api request' do
      before { stub_find_request_success(library_code: library_code, response_body: response_body) }

      it 'returns a Library::Info::Request instance' do
        expect(described_class.find(library_code: library_code)).to be_a(described_class)
      end
    end

    context 'with an unsuccessful api request' do
      before { stub_find_request_failure(library_code: library_code, response_body: response_body) }

      it 'raises an error ' do
        expect { described_class.find(library_code: library_code) }
          .to raise_error(Library::Info::Client::Error, /#{Library::Info::Client::ERROR_MESSAGE}/)
      end
    end
  end
end
