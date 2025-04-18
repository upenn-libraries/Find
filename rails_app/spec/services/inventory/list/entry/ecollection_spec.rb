# frozen_string_literal: true

describe Inventory::List::Entry::Ecollection do
  let(:entry) do
    create(
      :ecollection_entry,
      mms_id: '9956518803503681',
      id: '61585817810003681',
      public_note: '<a href="https://www.spam.com">Lippincott Library</a> On-site <span>Database</span>'
    )
  end

  describe '#id' do
    it 'returns expected id' do
      expect(entry.id).to eq '61585817810003681'
    end
  end

  describe '#description' do
    it 'returns expected value' do
      expect(entry.description).to eq 'Barclays Capital Live'
    end

    context 'when public_name_override is set' do
      let(:entry) { create(:ecollection_entry, :with_public_name_override) }

      it 'uses the override value' do
        expect(entry.description).to eq 'Penn Public Name'
      end
    end

    context 'when no expected values are present' do
      let(:entry) { create(:ecollection_entry, :with_no_name_provided) }

      it 'uses a default value' do
        expect(entry.description).to eq I18n.t('inventory.fallback_electronic_access_button_label')
      end
    end
  end

  describe '#public_note' do
    it 'returns expected public_note containing only allowed HTML tags' do
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
