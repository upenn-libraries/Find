# frozen_string_literal: true

describe Discover::Parser::ArtCollection do
  include FixtureHelpers

  let(:tsv) { tabular_fixture('art_collection', namespace: 'discover', format: :tsv) }
  let(:tsv_updated) { tabular_fixture('art_collection_updated', namespace: 'discover', format: :tsv) }

  context 'with new artworks' do
    let(:first_artwork) { Discover::ArtWork.first }

    before { described_class.import(file: tsv) }

    it 'creates artworks' do
      expect(Discover::ArtWork.count).to eq 10
    end

    it 'strips html tags in description' do
      expect(first_artwork.description).not_to match(/<[^>]*>/)
    end

    described_class::ARTWORK_ATTRIBUTES.each do |a|
      it "assigns #{a}" do
        expect(first_artwork.send(a)).not_to be_nil
      end
    end
  end

  context 'with updated artworks' do
    before { described_class.import(file: tsv) }

    it 'updates changed artworks' do
      format = Discover::ArtWork.first.format
      described_class.import(file: tsv_updated)

      expect(Discover::ArtWork.first.format).not_to eq format
    end

    it 'does not update unchanged artworks' do
      attr = Discover::ArtWork.second.attributes
      described_class.import(file: tsv_updated)

      expect(Discover::ArtWork.second.attributes).to eq attr
    end
  end
end
