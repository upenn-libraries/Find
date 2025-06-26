# frozen_string_literal: true

describe AlmaSRU::Bib do
  include FixtureHelpers
  include Alma::SRUMocks::Bib

  describe '.get_availability' do
    let(:availability) { described_class.get_availability(mms_id: mms_id) }

    context 'when a record is found' do
      let(:mms_id) { '999763063503681' }
      let(:response_body) { sru_xml_fixture 'physical_bib_availability' }

      before { stub_sru_response id: mms_id, response_body: response_body }

      it 'returns expected data' do
        expect(availability).to be_an AlmaSRU::Response::Availability
      end
    end

    context 'when a record is not found' do
      let(:mms_id) { '9999' }
      let(:response_body) { sru_xml_fixture 'record_not_found' }

      before { stub_sru_response id: mms_id, response_body: response_body }

      it 'raise an exception' do
        expect { availability }.to raise_error StandardError
      end
    end

    context 'with an error' do
      let(:mms_id) { 'cheese' }
      let(:response_body) { sru_xml_fixture 'error' }

      before { stub_sru_response id: mms_id, response_body: response_body }

      it 'raises an exception' do
        expect { availability }.to raise_error StandardError
      end
    end
  end
end
