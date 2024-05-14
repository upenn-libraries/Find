# frozen_string_literal: true

describe Shelf::Entry::IllTransaction do
  let(:illiad_transaction) { create(:illiad_request, :loan) }
  let(:display_status_set) { create(:illiad_display_status_set) }
  let(:transaction) { described_class.new(illiad_transaction, display_status_set) }

  describe '.new' do
    it 'sets transaction' do
      expect(transaction.request).not_to be_nil
    end

    it 'sets display statues' do
      expect(transaction.display_statuses).not_to be_nil
    end
  end

  describe '#id' do
    it 'returns expected id' do
      expect(transaction.id).to eql illiad_transaction.data[:TransactionNumber]
    end
  end

  describe '#title' do
    context 'when loan' do
      it 'returns expected title' do
        expect(transaction.title).to eql illiad_transaction.data[:LoanTitle]
      end
    end

    context 'when scan' do
      let(:illiad_transaction) { create(:illiad_request, :scan) }

      it 'returns expected title' do
        expect(transaction.title).to eql illiad_transaction.data[:PhotoJournalTitle]
      end
    end
  end

  describe '#author' do
    context 'when loan' do
      it 'returns expected author' do
        expect(transaction.author).to eql illiad_transaction.data[:LoanAuthor]
      end
    end

    context 'when scan' do
      let(:illiad_transaction) { create(:illiad_request, :scan) }

      it 'returns expected author' do
        expect(transaction.author).to eql illiad_transaction.data[:PhotoJournalAuthor]
      end
    end
  end

  describe '#mms_id' do
    it 'returns nil' do
      expect(transaction.mms_id).to be_nil
    end
  end

  describe '#status' do
    context 'when completed borrow direct loan' do
      let(:illiad_transaction) { create(:illiad_request, :completed_borrow_direct_loan) }

      it 'returns expected status' do
        expect(transaction.status).to eql 'Shipped by BorrowDirect Partner'
      end
    end

    context 'when status has a display status available' do
      it 'returns expected display status' do
        expect(transaction.status).to eql 'In Process'
      end
    end

    context 'when status does not have a display status available' do
      let(:illiad_transaction) { create(:illiad_request, :cancelled) }

      it 'returns expected status' do
        expect(transaction.status).to eql 'Cancelled By ILL Staff'
      end
    end
  end

  describe '#last_updated_at' do
    it 'returns expected last updated at date' do
      expect(transaction.last_updated_at).to be_a Time
      # TODO: strftime('%FT%R%S%3N' )
      expect(transaction.last_updated_at).to eql illiad_transaction.date
    end
  end

  describe '#borrow_direct_identifier' do
    context 'when a completed borrow direct transaction' do
      let(:illiad_transaction) { create(:illiad_request, :completed_borrow_direct_loan) }

      it 'returns expected borrow direct identifier' do
        expect(transaction.borrow_direct_identifier).to eql illiad_transaction.data[:ILLNumber]
      end
    end

    context 'when not a completed borrow direct transaction' do
      it 'returns nil' do
        expect(transaction.borrow_direct_identifier).to be_nil
      end
    end
  end

  describe '#system' do
    it 'returns expected system' do
      expect(transaction.system).to eql Shelf::Entry::Base::ILL
    end
  end

  describe '#type' do
    it 'returns expected type' do
      expect(transaction.type).to be :transaction
    end
  end

  describe '#ils_loan?' do
    it 'returns false' do
      expect(transaction.ils_loan?).to be false
    end
  end

  describe '#ils_hold?' do
    it 'returns false' do
      expect(transaction.ils_hold?).to be false
    end
  end

  describe '#ill_transaction?' do
    it 'returns true' do
      expect(transaction.ill_transaction?).to be true
    end
  end
end
