# frozen_string_literal: true

describe Inventory::List::Entry::Ecollection do
  let(:entry) do
    create(
      :ecollection_entry,
      mms_id: '9956518803503681',
      id: '61585817810003681',
      public_note: 'Lippincott Library On-site Database'
    )
  end

  describe '#id' do
    it 'returns expected id' do
      expect(entry.id).to eq '61585817810003681'
    end
  end

  describe '#public_note' do
    it 'returns expected public_note' do
      expect(entry.public_note).to eql 'Lippincott Library On-site Database'
    end
  end

  describe '#electronic?' do
    it 'returns true' do
      expect(entry.electronic?).to be true
    end
  end

  describe '#ecollection?' do
    it 'returns true' do
      expect(entry.ecollection?).to be true
    end
  end

  describe '#physical?' do
    it 'returns false' do
      expect(entry.physical?).to be false
    end
  end

  describe '#resource_link?' do
    it 'returns false' do
      expect(entry.resource_link?).to be false
    end
  end
end
