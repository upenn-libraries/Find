# frozen_string_literal: true

describe Inventory::List::Entry::Electronic do
  let(:entry) do
    create(
      :electronic_entry,
      mms_id: '9977047322103681',
      portfolio_pid: '53496697910003681',
      collection_id: '61496697940003681',
      activation_status: Inventory::Constants::ELEC_AVAILABLE,
      library_code: 'VanPeltLib',
      collection: 'Nature Publishing Journals',
      coverage_statement: 'Available from 1869 volume: 1 issue: 1.',
      public_note: 'Note: Use this link for Penn-sponsored access to Nature.',
      interface_name: 'Nature',
      inventory_type: Inventory::List::ELECTRONIC
    )
  end

  describe '#status' do
    it 'returns expected status' do
      expect(entry.status).to eq Inventory::Constants::ELEC_AVAILABLE
    end
  end

  describe '#human_readable_status' do
    it 'returns expected human_readable_status' do
      expect(entry.human_readable_status).to eq I18n.t('alma.availability.electronic.available.label')
    end
  end

  describe '#id' do
    it 'returns expected id' do
      expect(entry.id).to eq '53496697910003681'
    end
  end

  describe '#description' do
    it 'returns expected description' do
      expect(entry.description).to eql 'Nature Publishing Journals'
    end

    context 'when no collection value is present' do
      let(:entry) { create(:electronic_entry, :without_collection) }

      it 'returns the default value' do
        expect(entry.description).to eq I18n.t('inventory.fallback_electronic_access_button_label')
      end
    end
  end

  describe '#coverage_statement' do
    it 'returns expected coverage_statement' do
      expect(entry.coverage_statement).to eql 'Available from 1869 volume: 1 issue: 1.'
    end
  end

  describe '#public_note' do
    it 'returns expected public_note' do
      expect(entry.public_note).to eql 'Note: Use this link for Penn-sponsored access to Nature.'
    end
  end

  describe '#href' do
    it 'returns the expected URI' do
      expect(entry.href).to eq(
        "https://#{Inventory::Constants::ERESOURCE_LINK_HOST}#{Inventory::Constants::ERESOURCE_LINK_PATH}?" \
        "Force_direct=true&test_access=true&portfolio_pid=#{entry.id}&" \
        "rfr_id=#{CGI.escape(Inventory::Constants::ERESOURCE_LINK_RFR_ID)}&u.ignore_date_coverage=true"
      )
    end
  end

  describe '#human_readable_location' do
    it 'returns nil' do
      expect(entry.human_readable_location).to be_nil
    end
  end

  describe '#policy' do
    it 'returns nil' do
      expect(entry.policy).to be_nil
    end
  end

  describe '#format' do
    it 'returns nil' do
      expect(entry.format).to be_nil
    end
  end

  describe '#collection_id' do
    it 'returns expected value' do
      expect(entry.collection_id).to eql '61496697940003681'
    end
  end

  describe '#electronic?' do
    it 'returns true' do
      expect(entry.electronic?).to be true
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
