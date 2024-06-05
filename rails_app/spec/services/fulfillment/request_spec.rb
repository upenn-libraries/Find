# frozen_string_literal: true

describe Fulfillment::Request do
  describe '#endpoint' do
    context 'with requests destined for Illiad' do
      let(:destination) { Fulfillment::Endpoint::Illiad }

      it 'properly returns the endpoint for Books by Mail requests' do
        request = build(:fulfillment_request, :books_by_mail)
        expect(request.endpoint).to eq destination
      end

      it 'properly returns the endpoint for scan requests' do
        request = build(:fulfillment_request, :scan_deliver)
        expect(request.endpoint).to eq destination
      end

      it 'properly returns the endpoint for office delivery requests' do
        request = build(:fulfillment_request, :office_delivery)
        expect(request.endpoint).to eq destination
      end

      it 'properly returns the endpoint for ILL item pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_bib)
        expect(request.endpoint).to eq destination
      end
    end

    context 'with requests destined for Alma' do
      let(:destination) { Fulfillment::Endpoint::Alma }

      it 'properly returns the endpoint for Alma item pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_item)
        expect(request.endpoint).to eq destination
      end

      it 'properly returns the endpoint for Alma holding pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_holding)
        expect(request.endpoint).to eq destination
      end
    end

    context 'with requests destined for Aeon' do
      let(:destination) { Fulfillment::Endpoint::Aeon }

      it 'properly returns the endpoint for Aeon requests' do
        request = build(:fulfillment_request, :aeon)
        expect(request.endpoint).to eq destination
      end
    end
  end
end
