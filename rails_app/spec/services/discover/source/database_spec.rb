# frozen_string_literal: true

describe Discover::Source::Database do
  let(:database_source) { described_class.new(source: source) }

  describe '#results' do
    context 'with an Art Collection source' do
      let(:source) { Discover::Configuration::Database::ArtCollection::SOURCE }
      let(:art_work) { create(:art_work) }
      let(:results) { database_source.results(query: art_work.title) }

      before { art_work }

      it 'returns a Results object' do
        expect(results).to be_a(Discover::Results)
      end

      it 'assigns a total count' do
        expect(results.total_count).to eq(1)
      end

      it 'assigns a results url' do
        expect(results.results_url).to eq("https://pennartcollection.com/?s=#{art_work.title}")
      end

      it 'assigns expected record title' do
        expect(results.first.title).to contain_exactly(art_work.title)
      end

      it 'assigns expected record description' do
        expect(results.first.description).to eq([art_work.description])
      end
    end
  end

  describe '#blacklight?' do
    it 'returns false' do
      expect(described_class.new(source: 'art_collection').blacklight?).to be false
    end
  end

  describe '#pse?' do
    it 'returns false' do
      expect(described_class.new(source: 'art_collection').pse?).to be false
    end
  end

  describe '#database?' do
    it 'returns true' do
      expect(described_class.new(source: 'art_collection').database?).to be true
    end
  end
end
