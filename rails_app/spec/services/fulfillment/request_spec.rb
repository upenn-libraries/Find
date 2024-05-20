# frozen_string_literal: true

describe Fulfillment::Request do
  describe '#destination' do
    context 'with requests destined for Illiad' do
      it 'properly returns the destination for Books by Mail requests' do
        request = build(:fulfillment_request, :books_by_mail)
        expect(request.destination).to eq :illiad
      end

      it 'properly returns the destination for scan requests' do
        request = build(:fulfillment_request, :scan_deliver)
        expect(request.destination).to eq :illiad
      end

      it 'properly returns the destination for office delivery requests' do
        request = build(:fulfillment_request, :office_delivery)
        expect(request.destination).to eq :illiad
      end

      it 'properly returns the destination for ILL item pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_bib)
        expect(request.destination).to eq :illiad
      end
    end

    context 'with requests destined for Alma' do
      it 'properly returns the destination for Alma item pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_item)
        expect(request.destination).to eq :alma
      end

      it 'properly returns the destination for Alma holding pickup requests' do
        request = build(:fulfillment_request, :pickup, :with_holding)
        expect(request.destination).to eq :alma
      end
    end

    context 'with requests destined for Aeon' do
      it 'properly returns the destination for Aeon requests' do
        request = build(:fulfillment_request, :aeon)
        expect(request.destination).to eq :aeon
      end
    end
  end
end
