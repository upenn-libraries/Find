# frozen_string_literal: true

describe Discover::Parser::ArtCollection do
  include FixtureHelpers

  let(:tsv) { tabular_fixture_file('art_collection', namespace: 'discover', format: :tsv).read }

  context 'when creating artworks' do
    let(:first_artwork) { Discover::ArtWork.first }

    before { described_class.import(file: tsv) }

    it 'first truncates the table' do
      artwork = create(:art_work)
      expect(Discover::ArtWork.find(artwork.id)).to eq artwork
      described_class.import(file: tsv)
      expect { Discover::ArtWork.find(artwork.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

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

  context 'when there is an error' do
    it 'rolls back the database actions' do
      allow(CSV).to receive(:parse).and_raise(StandardError)
      create(:art_work)
      expect(Discover::ArtWork.count).to eq 1
      described_class.import(file: tsv)
      expect(Discover::ArtWork.count).to eq 1
    end
  end
end
