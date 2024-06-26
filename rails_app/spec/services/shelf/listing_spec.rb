# frozen_string_literal: true

describe Shelf::Listing do
  let(:entries) do
    [create(:ils_loan),
     create(:ils_hold),
     create(:ill_transaction),
     create(:ils_loan, :borrow_direct),
     create(:ill_transaction, :completed_borrow_direct_loan)]
  end
  let(:listing) { create(:shelf_listing, entries: entries) }

  describe '.new' do
    it 'returns expected amount of entries' do
      expect(listing.count).to be 4
    end

    it 'removes expected entry' do
      ill_transactions = listing.select(&:ill_transaction?)
      expect(ill_transactions.count).to be 1
      expect(ill_transactions.first.borrow_direct_identifier).to be nil
    end

    it 'sorts entries' do
      expect(listing.first.last_updated_at).to(satisfy { |d| d > listing.to_a.second.last_updated_at })
    end

    context 'when filtering entries' do
      let(:listing) { create(:shelf_listing, entries: entries, filters: [:requests]) }

      it 'filters entries' do
        expect(listing.count).to be 2
        expect(listing.all? { |e| e.ill_transaction? || e.ils_hold? }).to be true
      end
    end
  end

  describe '#loans?' do
    context 'when loans are present' do
      it 'returns true' do
        expect(listing.loans?).to be true
      end
    end

    context 'when loans are not present' do
      let(:entries) do
        [create(:ils_hold), create(:ill_transaction)]
      end

      it 'returns false' do
        expect(listing.loans?).to be false
      end
    end
  end
end
