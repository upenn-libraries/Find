# frozen_string_literal: true

describe Fulfillment::Endpoint::Alma do
  describe '.validate' do
    subject(:errors) { described_class.validate(request: bad_request) }

    context 'when pickup location missing' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, pickup_location: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_pickup_location')
      end
    end

    context 'when mms_id missing' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, mms_id: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_mms_id')
      end
    end

    context 'when holding_id missing' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, holding_id: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_holding_id')
      end
    end

    context 'when missing patron' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, requester: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_user_id')
      end
    end

    context 'when request proxied' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :pickup, :proxied) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_proxy_requests')
      end
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
