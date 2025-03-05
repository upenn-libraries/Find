# frozen_string_literal: true

describe Discover::Parser::ArtCollection do
  include Discover::ApiMocks::Parser
  include FixtureHelpers

  context 'with new artworks' do
    it 'creates artworks' do
      expect { described_class.import(file: tsv_fixture('art_collection')) }
        .to change(Discover::ArtWork, :count).by(9)
    end
  end

  context 'with updated artworks' do
    before { described_class.import(file: tsv_fixture('art_collection')) }

    it 'updates changed artworks' do
      format = Discover::ArtWork.first.format
      described_class.import(file: tsv_fixture('art_collection_updated'))

      expect(Discover::ArtWork.first.format).not_to eq format
    end

    it 'does not update unchanged artworks' do
      format = Discover::ArtWork.second.format
      updated_at = Discover::ArtWork.second.updated_at
      described_class.import(file: tsv_fixture('art_collection_updated'))

      expect(Discover::ArtWork.second.format).to eq format
      expect(Discover::ArtWork.second.updated_at).to eq updated_at
    end
  end
end
