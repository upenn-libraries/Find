# frozen_string_literal: true

describe Inventory::List::Entry::ResourceLink do
  let(:entry) do
    create(:resource_link_entry, id: '1', href: 'http://example.com', description: 'Digital Edition')
  end

  describe '#status' do
    it 'returns expected status' do
      expect(entry.status).to eq Inventory::Constants::AVAILABLE
    end
  end

  describe '#human_readable_status' do
    it 'returns expected human_readable_status' do
      expect(entry.human_readable_status).to eq I18n.t('alma.availability.electronic.available.label')
    end
  end

  describe '#description' do
    it 'returns expected description' do
      expect(entry.description).to eql 'Digital Edition'
    end
  end

  describe '#id' do
    it 'returns the expected id' do
      expect(entry.id).to eq "#{Inventory::List::Entry::ResourceLink::ID_PREFIX}1"
    end
  end

  describe '#href' do
    it 'returns the expected href' do
      expect(entry.href).to eql 'http://example.com'
    end
  end

  describe '#format' do
    it 'returns nil' do
      expect(entry.format).to be_nil
    end
  end

  describe '#policy' do
    it 'returns nil' do
      expect(entry.policy).to be_nil
    end
  end

  describe '#coverage_statement' do
    it 'returns nil' do
      expect(entry.coverage_statement).to be_nil
    end
  end

  describe '#location' do
    it 'returns expected location' do
      expect(entry.location).to eq 'Online'
    end
  end

  describe '#electronic?' do
    it 'returns false' do
      expect(entry.electronic?).to be false
    end
  end

  describe '#physical?' do
    it 'returns false' do
      expect(entry.physical?).to be false
    end
  end

  describe '#resource_link?' do
    it 'returns true' do
      expect(entry.resource_link?).to be true
    end
  end
end
