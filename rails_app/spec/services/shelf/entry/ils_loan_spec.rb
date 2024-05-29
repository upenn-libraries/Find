# frozen_string_literal: true

describe Shelf::Entry::IlsLoan do
  let(:alma_loan) { create(:alma_loan) }
  let(:loan) { described_class.new(alma_loan.response) }

  describe '.new' do
    it 'sets raw_data' do
      expect(loan.raw_data).not_to be_nil
    end
  end

  describe '#id' do
    it 'returns expected id' do
      expect(loan.id).to eql alma_loan.loan_id
    end
  end

  describe '#title' do
    it 'returns expected title' do
      expect(loan.title).to eql alma_loan.title
    end
  end

  describe '#author' do
    it 'returns expected author' do
      expect(loan.author).to eql alma_loan.author
    end
  end

  describe '#mms_id' do
    context 'when not a resource sharing loan' do
      it 'returns expected mms_id' do
        expect(loan.mms_id).to eql alma_loan.mms_id
      end
    end

    context 'when it is a resource sharing loan' do
      let(:alma_loan) { create(:alma_loan, :resource_sharing) }

      it 'returns nil' do
        expect(loan.mms_id).to be_nil
      end
    end
  end

  describe '#status' do
    context 'when overdue' do
      let(:alma_loan) { create(:alma_loan, :overdue) }

      it 'returns expected status' do
        expect(loan.status).to eql 'OVERDUE'
      end
    end

    context 'when not overdue' do
      it 'returns expected status' do
        expect(loan.status).to match(%r{\d{2}/\d{2}/\d{2}})
      end
    end
  end

  describe '#barcode' do
    it 'returns expected barcode' do
      expect(loan.barcode).to eql alma_loan.item_barcode
    end
  end

  describe '#due_date' do
    it 'returns expected due_date' do
      expect(loan.due_date).to be_a Time
      expect(loan.due_date.utc.iso8601).to eql alma_loan.due_date
    end
  end

  describe '#last_updated_at' do
    context 'when renewed' do
      let(:alma_loan) { create(:alma_loan, :renewed) }

      it 'returns date it last renewed' do
        expect(loan.last_updated_at).to be_a Time
        expect(loan.last_updated_at.utc.iso8601(3)).to eql alma_loan.last_renew_date
      end
    end

    context 'when not renewed' do
      it 'returns loan date' do
        expect(loan.last_updated_at).to be_a Time
        expect(loan.last_updated_at.utc.iso8601(3)).to eql alma_loan.loan_date
      end
    end
  end

  describe '#renewable?' do
    context 'when renewable data present' do
      let(:alma_loan) { create(:alma_loan, :renewable) }

      it 'returns true' do
        expect(loan.renewable?).to be true
      end
    end

    context 'when renewable data not present' do
      it 'raises an error' do
        expect { loan.renewable? }.to raise_error Shelf::Service::AlmaRequestError, 'Renewable attribute unavailable'
      end
    end
  end

  describe '#resource_sharing?' do
    context 'when resource sharing loan' do
      let(:alma_loan) { create(:alma_loan, :resource_sharing) }

      it 'returns true' do
        expect(loan.resource_sharing?).to be true
      end
    end

    context 'when not a resource sharing loan' do
      it 'returns false' do
        expect(loan.resource_sharing?).to be false
      end
    end
  end

  describe '#system' do
    it 'returns expected system' do
      expect(loan.system).to eql Shelf::Entry::Base::ILS
    end
  end

  describe '#type' do
    it 'returns expected type' do
      expect(loan.type).to be :loan
    end
  end

  describe '#ils_loan?' do
    it 'returns true' do
      expect(loan.ils_loan?).to be true
    end
  end

  describe '#ils_hold?' do
    it 'returns false' do
      expect(loan.ils_hold?).to be false
    end
  end

  describe '#ill_transaction?' do
    it 'returns false' do
      expect(loan.ill_transaction?).to be false
    end
  end
end
