# frozen_string_literal: true

describe Shelf::Listing do
  let(:entries) do
    [create(:ils_loan),
     create(:ils_hold),
     create(:ill_transaction),
     create(:ils_loan, :borrow_direct),
     create(:ill_transaction, :completed_borrow_direct_loan)]
  end
  let(:listing) { create(:shelf_listing, entries: entries, sort: sort_option, order: sort_order) }
  let(:sort_option) { Shelf::Service::LAST_UPDATED_AT }
  let(:sort_order) { Shelf::Service::DESCENDING }

  describe '.new' do
    it 'returns expected amount of entries' do
      expect(listing.count).to be 4
    end

    it 'removes expected entry' do
      ill_transactions = listing.select(&:ill_transaction?)
      expect(ill_transactions.count).to be 1
      expect(ill_transactions.first.borrow_direct_identifier).to be_nil
    end

    it 'sorts entries by last updated at value' do
      expect(listing.first.send(sort_option)).to(satisfy { |d| d > listing.to_a.second.send(sort_option) })
    end

    context 'when sorting by due date' do
      let(:sort_option) { Shelf::Service::DUE_DATE }
      let(:entries) do
        [create(:ils_loan, :overdue),
         create(:ils_loan, :due_in_five_days),
         create(:ils_loan, :due_in_ten_days),
         create(:ill_transaction),
         create(:ils_hold)]
      end

      context 'when using descending order' do
        it 'sorts items with no due date to the bottom' do
          expect(listing.to_a[3..4]).to(satisfy { |d| d.all? { |e| e.due_date.nil? } })
        end

        it 'sorts the item properly by due date in descending order' do
          expect(listing.to_a[0..1]).to(satisfy { |d| d.first.due_date > d.second.due_date })
          expect(listing.to_a[1..2]).to(satisfy { |d| d.first.due_date > d.second.due_date })
        end
      end

      context 'when using ascending order' do
        let(:sort_order) { Shelf::Service::ASCENDING }

        it 'sorts items with no due date to the bottom' do
          expect(listing.to_a[3..4]).to(satisfy { |d| d.all? { |e| e.due_date.nil? } })
        end

        it 'sorts the item properly by due date in ascending order' do
          expect(listing.to_a[0..1]).to(satisfy { |d| d.first.due_date < d.second.due_date })
          expect(listing.to_a[1..2]).to(satisfy { |d| d.first.due_date < d.second.due_date })
        end
      end
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
