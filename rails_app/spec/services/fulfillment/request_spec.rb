# frozen_string_literal: true

describe Fulfillment::Request do
  describe '#new' do
    context 'when request is not proxied' do
      let(:request) { create(:fulfillment_request, :ill_pickup) }

      it 'sets the same user as the requester and patron' do
        expect(request.requester).to eql request.patron
      end
    end

    context 'when it\'s a proxied request' do
      let(:request) { create(:fulfillment_request, :ill_pickup, :proxied) }

      it 'creates a new user for proxied patron' do
        expect(request.patron).to be_a Fulfillment::User
        expect(request.patron.uid).to eql 'jdoe'
      end

      it 'sets the correct user as the requester' do
        expect(request.requester).to be_a User
        expect(request.requester.uid).not_to eql 'jdoe'
      end
    end

    context 'when an endpoint is provided' do
      let(:request) { create(:fulfillment_request, :ill_pickup, :illiad) }

      it 'sets the correct endpoint' do
        expect(request.endpoint).to be Fulfillment::Endpoint::Illiad
      end
    end
  end

  describe '#proxied?' do
    context 'when request is proxied' do
      let(:request) { create(:fulfillment_request, :ill_pickup, :proxied) }

      it 'returns true' do
        expect(request.proxied?).to be true
      end
    end

    context 'when request is not proxied' do
      let(:request) { create(:fulfillment_request, :ill_pickup) }

      it 'returns false' do
        expect(request.proxied?).to be false
      end
    end
  end

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
        request = build(:fulfillment_request, :ill_pickup)
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

    # context 'with requests destined for Aeon' do
    #   let(:destination) { Fulfillment::Endpoint::Aeon }
    #
    #   it 'properly returns the endpoint for Aeon requests' do
    #     request = build(:fulfillment_request, :aeon)
    #     expect(request.endpoint).to eq destination
    #   end
    # end
  end
end
