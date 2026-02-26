# frozen_string_literal: true

describe Discover::Parser::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:csv) { tabular_fixture('penn_museum', namespace: :discover) }

  describe '.import' do
    let(:first_artifact) { Discover::Artifact.first }

    def import_csv(csv_data)
      stub_csv_download_response(status: 200, body: csv_data)
      Discover::Harvester::PennMuseum.new.harvest { |file| described_class.import(file: file) }
    end

    context 'with new artifacts' do
      before { import_csv(csv) }

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
        import_csv(csv)
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
      let(:csv_updated) { tabular_fixture('penn_museum_updated', namespace: :discover) }

      before { import_csv(csv) }

      it 'updates changed artifacts' do
        format = Discover::Artifact.first.format
        import_csv(csv_updated)

        expect(Discover::Artifact.first.format).not_to eq format
      end

      it 'does not update unchanged artifacts' do
        attr = Discover::Artifact.second.attributes
        import_csv(csv_updated)

        expect(Discover::Artifact.second.attributes).to eq attr
      end

      it 'adds new artifacts' do
        import_csv(csv_updated)

        expect(Discover::Artifact.count).to eq 4
      end
    end
  end

  describe '.delete_missing' do
    let(:csv) { tabular_fixture('penn_museum', namespace: :discover) }
    let(:csv_with_removal) { tabular_fixture('penn_museum_with_removals', namespace: :discover) }

    def import_csv(csv_data)
      stub_csv_download_response(status: 200, body: csv_data)
      Discover::Harvester::PennMuseum.new.harvest { |file| described_class.import(file: file) }
    end

    def delete_missing_csv(csv_data)
      stub_csv_download_response(status: 200, body: csv_data)
      Discover::Harvester::PennMuseum.new.harvest { |file| described_class.delete_missing(file: file) }
    end

    before { import_csv(csv) }

    it 'removes existing records not included in the csv data' do
      expect {
        delete_missing_csv(csv_with_removal)
      }.to change(Discover::Artifact, :count).from(3).to(1)
    end
  end
end
