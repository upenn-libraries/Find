# frozen_string_literal: true

describe Fulfillment::Endpoint::Alma do
  describe '.validate' do
    let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, requester: nil) }

    it 'adds error messages to errors' do
      expect(described_class.validate(request: bad_request)).to(
        match_array([I18n.t('fulfillment.validation.no_user_id')])
      )
    end
  end

  describe '.submit' do
    context 'with a successful item-level request' do
      let(:item_level_request) { build(:fulfillment_request, :with_item, :pickup) }
      let(:response_hash) { { 'request_id' => '1234' } }

      before do
        mock_response = instance_double(Alma::Response)
        allow(mock_response).to receive(:raw_response).and_return(response_hash)
        allow(::Alma::ItemRequest).to receive(:submit).and_return mock_response
      end

      it 'returns an outcome with the confirmation number' do
        outcome = described_class.submit(request: item_level_request)
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ALMA_1234'
      end
    end

    context 'with a successful holding-level request' do
      let(:item_level_request) { build(:fulfillment_request, :with_holding, :pickup) }
      let(:response_hash) { { 'request_id' => '1234' } }

      before do
        mock_response = instance_double(Alma::Response)
        allow(mock_response).to receive(:raw_response).and_return(response_hash)
        allow(::Alma::BibRequest).to receive(:submit).and_return mock_response
      end

      it 'returns an outcome with the confirmation number' do
        outcome = described_class.submit(request: item_level_request)
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ALMA_1234'
      end
    end
  end
end
