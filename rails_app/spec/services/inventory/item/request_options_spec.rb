# frozen_string_literal: true

describe Inventory::Item::RequestOptions do
  describe '#fulfillment_options' do
    let(:user) { create(:user) }
    let(:options) { item.request_options(user: user) }
    let(:item) { build :item, :checkoutable }

    it 'returns an array of options' do
      expect(options).to be_an Array
    end

    context 'when the item is aeon requestable' do
      let(:item) { build :item, :aeon_requestable }

      context 'with user' do
        it 'returns only aeon option' do
          expect(options).to eq [:aeon]
        end
      end

      context 'without user' do
        let(:user) { nil }

        it 'returns only aeon option' do
          expect(options).to eq [:aeon]
        end
      end
    end

    context 'when the item is at archives' do
      let(:item) { build :item, :at_archives }

      context 'with user' do
        it 'returns only archives option' do
          expect(options).to eq [:archives]
        end
      end

      context 'without user' do
        let(:user) { nil }

        it 'returns only archives option' do
          expect(options).to eq [:archives]
        end
      end
    end

    context 'when the item is checkoutable' do
      let(:item) { build :item, :checkoutable }

      it 'returns pickup option' do
        expect(options).to include Fulfillment::Request::Options::PICKUP
      end

      it 'returns electronic option if item is scannable' do
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end

      it 'returns mail option if user is not courtesy borrower' do
        expect(options).to include Fulfillment::Request::Options::MAIL
      end

      context 'with faculty express user' do
        let(:user) { create(:user, :faculty_express) }

        it 'returns office option' do
          expect(options).to include Fulfillment::Request::Options::OFFICE
        end
      end

      context 'with courtesy borrower' do
        let(:user) { create(:user, :courtesy_borrower) }

        it 'returns only pickup option' do
          expect(options).to contain_exactly(Fulfillment::Request::Options::PICKUP)
        end
      end
    end

    context 'when the item is unavailable because it does not circulate' do
      let(:item) { build :item, :not_checkoutable }

      it 'returns noncirc option' do
        expect(options).to include Fulfillment::Request::Options::NONCIRC
      end
    end
  end
end
