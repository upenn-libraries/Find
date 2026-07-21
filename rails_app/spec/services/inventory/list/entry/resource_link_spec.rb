# frozen_string_literal: true

describe Inventory::List::Entry::ResourceLink do
  let(:entry) do
    create(:resource_link_entry, id: '1', link_url: 'http://example.com', link_text: 'Digital Edition')
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
    context 'when hostname is mapped to website name' do
      let(:entry) { create(:digital_collections_resource_link_entry) }

      it 'returns website name' do
        expect(entry.description).to eq 'Digital Collections'
      end
    end

    context 'when hostname is not mapped to website name' do
      it 'returns link_text' do
        expect(entry.description).to eql 'Digital Edition'
      end
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
    context 'when hostname is mapped to website name' do
      let(:entry) { create(:digital_collections_resource_link_entry) }

      it 'returns link_text' do
        expect(entry.coverage_statement).to eq 'Full Resource'
      end
    end

    context 'when hostname is not mapped to website name' do
      it 'returns coverage_statement' do
        expect(entry.coverage_statement).to be_nil
      end
    end
  end

  describe '#human_readable_location' do
    it 'returns nil' do
      expect(entry.human_readable_location).to be_nil
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

  describe '#displayable?' do
    let(:entry) { create(:resource_link_entry, link_url: link_value, link_text: 'Digital Edition') }

    context 'when an href value is present' do
      let(:link_value) { 'http://example.com' }

      it 'returns true' do
        expect(entry.displayable?).to be true
      end
    end

    context 'when an href value is present, but includes errant whitespace' do
      let(:link_value) { ' http://www.example.com ' }

      it 'returns true' do
        expect(entry.displayable?).to be true
      end
    end

    context 'when an href value is not present' do
      let(:link_value) { '' }

      it 'returns false' do
        expect(entry.displayable?).to be false
      end
    end
  end

  describe '#hostname' do
    context 'when href is valid url' do
      it 'returns hostname' do
        expect(entry.send(:hostname)).to eql 'example.com'
      end
    end

    context 'when href is not a valid url' do
      let(:entry) do
        create(:resource_link_entry, id: '1', link_url: '[invalid url]', link_text: 'Digital Edition')
      end

      it 'return nil' do
        expect(entry.send(:hostname)).to be_nil
      end
    end
  end
end
