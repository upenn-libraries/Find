# frozen_string_literal: true

describe Discover::Parser::ArtCollection do
  include FixtureHelpers

  let(:tsv) { tsv_fixture('art_collection') }
  let(:tsv_updated) { tsv_fixture('art_collection_updated') }

  context 'with new artworks' do
    let(:first_artwork) { Discover::ArtWork.first }

    before { described_class.import(file: tsv) }

    it 'creates artworks' do
      expect(Discover::ArtWork.count).to eq 10
    end

    it 'assigns title' do
      expect(first_artwork.title).not_to be_nil
    end

    it 'assigns link' do
      expect(first_artwork.link).not_to be_nil
    end

    it 'assigns identifier' do
      expect(first_artwork.identifier).not_to be_nil
    end

    it 'assigns thumbnail_url' do
      expect(first_artwork.thumbnail_url).not_to be_nil
    end

    it 'assigns location' do
      expect(first_artwork.location).not_to be_nil
    end

    it 'assigns format' do
      expect(first_artwork.format).not_to be_nil
    end

    it 'assigns creator' do
      expect(first_artwork.creator).not_to be_nil
    end

    it 'assigns description' do
      expect(first_artwork.description).not_to be_nil
    end

    it 'strips html tags in description' do
      expect(first_artwork.description).not_to match(/<[^>]*>/)
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
