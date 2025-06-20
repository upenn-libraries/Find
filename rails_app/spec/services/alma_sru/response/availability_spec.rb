# frozen_string_literal: true

describe AlmaSRU::Response::Availability do
  include FixtureHelpers

  let(:availability_response) { described_class.new(response_body) }

  describe '#holdings' do
    context 'with a print record' do
      let(:response_body) { sru_xml_fixture 'physical_bib_availability' }

      it 'returns expected data' do
        # TODO: fix array nesting. ensure multiple holdings are properly represented and check with spec
        expect(availability_response.holdings.first.first.keys).to include 'availability', 'location_code', 'holding_id'
      end
    end

    context 'with an electronic record' do
      let(:response_body) { sru_xml_fixture 'electronic_bib_availability' }

      it 'returns expected data' do
        expect(availability_response.holdings.first.first.keys).to include 'availability', 'collection', 'portfolio_pid'
      end
    end
  end
end
