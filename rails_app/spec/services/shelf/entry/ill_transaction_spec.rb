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
        expect(transaction.title).to include illiad_transaction.data[:PhotoJournalTitle]
        expect(transaction.title).to include illiad_transaction.data[:PhotoArticleTitle]
      end
    end

    context 'when loan with download' do
      let(:illiad_transaction) { create(:illiad_request, :loan_with_pdf_available) }

      it 'returns expected title' do
        expect(transaction.title).to include illiad_transaction.data[:LoanTitle]
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
        expect(transaction.author).to eql illiad_transaction.data[:PhotoArticleAuthor]
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
        expect(transaction.status).to eql Shelf::Entry::IllTransaction::Status::CANCELLED
      end
    end
  end

  describe '#last_updated_at' do
    it 'returns expected last updated at date' do
      expect(transaction.last_updated_at).to be_a Time
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

  describe '#expiry_date' do
    context 'when pdf scan available' do
      let(:illiad_transaction) { create(:illiad_request, :scan_with_pdf_available) }

      it 'returns expected date' do
        expect(transaction.expiry_date).to eql '04/14/24'
      end
    end

    context 'when pdf scan not available' do
      let(:illiad_transaction) { create(:illiad_request, :scan) }

      it 'returns nil' do
        expect(transaction.expiry_date).to be_nil
      end
    end
  end

  describe 'pdf_available?' do
    context 'when pdf is available' do
      let(:illiad_transaction) { create(:illiad_request, :scan_with_pdf_available) }

      it 'returns true' do
        expect(transaction.pdf_available?).to be true
      end
    end

    context 'when status is not available' do
      let(:illiad_transaction) { create(:illiad_request, :scan) }

      it 'returns false' do
        expect(transaction.pdf_available?).to be false
      end
    end
  end

  describe '#pdf' do
    context 'when pdf is not available for download' do
      it 'raises error' do
        expect { transaction.pdf }.to raise_error 'PDF not available'
      end
    end

    context 'when pdf is available' do
      let(:illiad_transaction) { create(:illiad_request, :scan_with_pdf_available) }

      it 'makes http request to Illiad server' do
        stub = stub_request(:get, "#{Shelf::Entry::IllTransaction::PDF_SCAN_LOCATION}#{transaction.id}.pdf")
        transaction.pdf
        expect(stub).to have_been_requested
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

  describe '#loan?' do
    context 'with request to loan' do
      it 'returns true' do
        expect(transaction.loan?).to be true
      end
    end

    context 'with a request to scan and no web delivery status' do
      let(:illiad_transaction) { build(:illiad_request, :scan) }

      it 'returns false' do
        expect(transaction.loan?).to be false
      end
    end

    context 'with a request to scan but with web delivery status' do
      let(:illiad_transaction) { build(:illiad_request, :loan_with_pdf_available) }

      it 'returns false' do
        expect(transaction.loan?).to be false
      end
    end
  end

  describe '#books_by_mail?' do
    context 'with a books by mail request' do
      let(:illiad_transaction) { build(:illiad_request, :books_by_mail) }

      it 'returns true for a books by mail request' do
        expect(transaction.books_by_mail?).to be true
      end
    end

    context 'with a non books by mail request' do
      it 'returns true for a books by mail request' do
        expect(transaction.books_by_mail?).to be false
      end
    end
  end

  describe '#scan?' do
    context 'with a request to loan' do
      it 'returns false' do
        expect(transaction.scan?).to be false
      end
    end

    context 'with a request to loan and web delivery status' do
      let(:illiad_transaction) { build(:illiad_request, :loan_with_pdf_available) }

      it 'returns true' do
        expect(transaction.scan?).to be true
      end
    end

    context 'with a request to scan' do
      let(:illiad_transaction) { build(:illiad_request, :scan) }

      it 'returns false' do
        expect(transaction.scan?).to be true
      end
    end
  end
end
