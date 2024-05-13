# frozen_string_literal: true

describe Shelf::Entry::IlsHold do
  let(:alma_hold) { create(:alma_hold) }
  let(:hold) { described_class.new(alma_hold.response) }

  describe '.new' do
    it 'sets raw_data' do
      expect(hold.raw_data).not_to be_nil
    end
  end

  describe '#id' do
    it 'returns expected id' do
      expect(hold.id).to eql alma_hold.request_id
    end
  end

  describe '#title' do
    it 'returns expected title' do
      expect(hold.title).to eql alma_hold.title
    end
  end

  describe '#author' do
    it 'returns expected author' do
      expect(hold.author).to eql alma_hold.author
    end
  end

  describe '#mms_id' do
    context 'when not a resource sharing hold' do
      it 'returns expected mms_id' do
        expect(hold.mms_id).to eql alma_hold.mms_id
      end
    end

    context 'when it is a resource sharing hold' do
      let(:alma_hold) { create(:alma_hold, :resource_sharing) }

      it 'returns nil' do
        expect(hold.mms_id).to be_nil
      end
    end
  end

  describe '#status' do
    context 'when on hold shelf' do
      let(:alma_hold) { create(:alma_hold, :on_hold_shelf) }

      it 'includes request status and expiry date' do
        expect(hold.status).to match(/^#{alma_hold.request_status.tr('_', ' ')} until \w+ \d{1,2}, \d{4}$/i)
      end
    end

    context 'when not on hold shelf' do
      it 'returns request status' do
        expect(hold.status).to match(/^#{alma_hold.request_status.tr('_', ' ')}$/i)
      end
    end
  end

  describe '#last_updated_at' do
    it 'returns expected last updated at date' do
      expect(hold.last_updated_at).to be_a Time
      expect(hold.last_updated_at.utc.iso8601(3)).to eql alma_hold.request_time
    end
  end

  describe '#barcode' do
    it 'returns expected barcode' do
      expect(hold.barcode).to eql alma_hold.barcode
    end
  end

  describe '#on_hold_shelf?' do
    context 'when on hold shelf' do
      let(:alma_hold) { create(:alma_hold, :on_hold_shelf) }

      it 'returns true' do
        expect(hold.on_hold_shelf?).to be true
      end
    end

    context 'when in progress' do
      it 'returns false' do
        expect(hold.on_hold_shelf?).to be false
      end
    end
  end

  describe '#expiry_date' do
    it 'returns expected expiry date' do
      expect(hold.expiry_date).to be_a Time
      expect(hold.expiry_date.utc.strftime('%FZ')).to eql alma_hold.expiry_date
    end
  end

  describe '#pickup_location' do
    it 'returns expected pickup_location' do
      expect(hold.pickup_location).to eql alma_hold.pickup_location
    end
  end

  describe '#resource_sharing?' do
    context 'when its a resource sharing hold' do
      let(:alma_hold) { create(:alma_hold, :resource_sharing) }

      it 'returns true' do
        expect(hold.resource_sharing?).to be true
      end
    end

    context 'when its not a resource sharing hold' do
      it 'returns false' do
        expect(hold.resource_sharing?).to be false
      end
    end
  end

  describe '#system' do
    it 'returns expected system' do
      expect(hold.system).to eql Shelf::Entry::Base::ILS
    end
  end

  describe '#type' do
    it 'returns expected type' do
      expect(hold.type).to eql :hold
    end
  end

  describe '#ils_loan?' do
    it 'returns false' do
      expect(hold.ils_loan?).to be false
    end
  end

  describe '#ils_hold?' do
    it 'returns true' do
      expect(hold.ils_hold?).to be true
    end
  end

  describe '#ill_transaction?' do
    it 'returns false' do
      expect(hold.ill_transaction?).to be false
    end
  end
end