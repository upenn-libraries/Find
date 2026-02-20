# frozen_string_literal: true

describe Discover::Parser::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:csv) { tabular_fixture('penn_museum', namespace: :discover) }
  let(:csv_updated) { tabular_fixture('penn_museum_updated', namespace: :discover) }

  def import_csv(csv_data)
    stub_csv_download_response(status: 200, body: csv_data)
    Discover::Harvester::PennMuseum.new.harvest { |file| described_class.import(file: file) }
  end

  context 'with new artifacts' do
    before { import_csv(csv) }

    let(:first_artifact) { Discover::Artifact.first }

    it 'creates artifacts' do
      expect(Discover::Artifact.count).to eq 2
    end

    it 'strips html tags in description' do
      expect(first_artifact.description).not_to match(/<[^>]*>/)
    end
  end

  context 'with updated artifacts' do
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
  end
end
