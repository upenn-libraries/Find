# frozen_string_literal: true

describe Hathi::Service do
  include Hathi::ApiMocks::Request

  let(:service) { described_class.new(identifiers: identifiers) }

  before do
    stub_single_id_request(request_url: service.send(:request_url), response_body: response)
  end

  describe '#link' do
    context 'with single ID when record exists in Hathi' do
      let(:identifiers) { { oclc: '12345' } }
      let(:response) do
        { 'oclc:12345': {
          'records': {
            '12345678': {
              'recordURL': 'https://catalog.hathitrust.org/Record/12345678'
            }
          }
        } }
      end

      it 'returns link' do
        expect(service.link).to eq('https://catalog.hathitrust.org/Record/12345678')
      end
    end

    context 'with multple IDs when record exists in Hathi' do
      let(:identifiers) { { oclc: '12345', isbn: '67890' } }
      let(:response) do
        { 'oclc:12345': {
          'records': {
            '12345678': {
              'recordURL': 'https://catalog.hathitrust.org/Record/12345678'
            }
          }
        }, 'isbn:67890': {
          'records': {
            '12345678': {
              'recordURL': 'https://catalog.hathitrust.org/Record/78901234'
            }
          }
        } }
      end

      it 'returns link from first match' do
        expect(service.link).to eq('https://catalog.hathitrust.org/Record/12345678')
      end
    end

    context 'when record does not exists in Hathi' do
      let(:identifiers) { { oclc: '12345' } }
      let(:response) do
        { "oclc:12345": { "records": [], "items": [] } }
      end

      before do
        stub_single_id_request(request_url: service.send(:request_url), response_body: response)
      end

      it 'returns nil' do
        expect(service.link).to be_nil
      end
    end
  end
end
