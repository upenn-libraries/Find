# frozen_string_literal: true

describe Discover::Parser::ArtCollection do
  include FixtureHelpers

  let(:tsv) { tsv_fixture('art_collection') }
  let(:tsv_updated) { tsv_fixture('art_collection_updated') }

  context 'with new artworks' do
    it 'creates artworks' do
      expect { described_class.import(file: tsv) }
        .to change(Discover::ArtWork, :count).by(9)
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
