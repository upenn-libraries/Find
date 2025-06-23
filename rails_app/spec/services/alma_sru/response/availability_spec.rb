# frozen_string_literal: true

describe AlmaSRU::Response::Availability do
  include FixtureHelpers

  let(:availability_response) { described_class.new(response_body: response_body, mms_id: mms_id) }
  let(:holdings) { availability_response.holdings[mms_id][:holdings] }

  describe '#holdings' do
    context 'with a print record' do
      let(:mms_id) { '994689523503681' }
      let(:response_body) { sru_xml_fixture 'physical_bib_availability' }

      it 'returns multiple holding records' do
        expect(holdings.length).to eq 2
      end

      it 'returns hash vales for a print record' do
        expect(holdings.first['inventory_type']).to eq 'physical'
        expect(holdings.first.keys).to include 'availability', 'location_code', 'holding_id'
      end
    end

    context 'with an electronic record' do
      let(:mms_id) { '9979240322003681' }
      let(:response_body) { sru_xml_fixture 'electronic_bib_availability' }

      it 'returns a single holding record' do
        expect(holdings.length).to eq 1
      end

      it 'returns hash vales for an electronic record' do
        expect(holdings.first['inventory_type']).to eq 'electronic'
        expect(holdings.first.keys).to include 'interface_name', 'collection', 'portfolio_pid'
      end
    end
  end
end
