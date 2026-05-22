# frozen_string_literal: true

describe Discover::Parser::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:csv) { tabular_fixture_file('penn_museum', namespace: :discover) }

  describe '.import' do
    let(:first_artifact) { Discover::Artifact.first }

    context 'with new artifacts' do
      before { described_class.import(file: csv) }

      it 'creates artifacts' do
        expect(Discover::Artifact.count).to eq 3
      end

      it 'strips html tags in description' do
        expect(first_artifact.description).not_to match(/<[^>]*>/)
      end
    end

    context 'with thumbnail mappings' do
      before do
        allow(Discover::Mappings).to receive(:museum_thumbnails).and_return(thumbnail_map)
        described_class.import(file: csv)
      end

      context 'with a match' do
        let(:thumbnail_map) { { '29-96-282A' => '1234' } }

        it 'sets a thumbnail value' do
          expect(first_artifact.thumbnail).to eq '1234_300.jpg'
        end
      end

      context 'with no match' do
        let(:thumbnail_map) { {} }

        it 'does not set a thumbnail value' do
          expect(first_artifact.thumbnail).to be_blank
        end
      end
    end

    context 'with updated artifacts' do
      let(:csv_updated) { tabular_fixture_file('penn_museum_updated', namespace: :discover) }

      before { described_class.import(file: csv) }

      it 'updates changed artifacts' do
        format = Discover::Artifact.first.format
        described_class.import file: csv_updated

        expect(Discover::Artifact.first.format).not_to eq format
      end

      it 'does not update unchanged artifacts' do
        attr = Discover::Artifact.second.attributes
        described_class.import file: csv_updated

        expect(Discover::Artifact.second.attributes).to eq attr
      end

      it 'adds new artifacts' do
        expect {
          described_class.import file: csv_updated
        }.to change(Discover::Artifact, :count).from(3).to(4)
      end
    end
  end

  describe '.delete_missing' do
    let(:csv) { tabular_fixture_file('penn_museum', namespace: :discover) }
    let(:csv_with_removal) { tabular_fixture_file('penn_museum_with_removals', namespace: :discover) }

    before { described_class.import(file: csv) }

    it 'removes existing records not included in the csv data' do
      expect {
        described_class.delete_missing(file: csv_with_removal)
      }.to change(Discover::Artifact, :count).from(3).to(1)
    end
  end
end
