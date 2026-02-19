# frozen_string_literal: true

describe Discover::Parser::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:csv) { tabular_fixture('penn_museum', namespace: :discover) }
  # TODO: need updated penn museum csv for updated record testing
  let(:csv_updated) { tabular_fixture('penn_museum_updated', namespace: :discover) }

  context 'with new artifacts' do
    before do
      stub_csv_download_response(status: 200, body: csv)
      Discover::Harvester::PennMuseum.new.harvest do |file|
        described_class.import(file: file)
      end
    end

    let(:first_artifact) { Discover::Artifact.first }

    it 'creates artifacts' do
      expect(Discover::Artifact.count).to eq 2
    end

    it 'strips html tags in description' do
      expect(first_artifact.description).not_to match(/<[^>]*>/)
    end

    described_class::ARTIFACT_ATTRIBUTES.each do |a|
      it "assigns #{a}" do
        expect(first_artifact.send(a)).not_to be_nil
      end
    end
  end

  context 'with updated artifacts' do
    before do
      stub_csv_download_response(status: 200, body: csv_updated)
      Discover::Harvester::PennMuseum.new.harvest do |file|
        described_class.import(file: file)
      end
    end

    it 'updates changed artifacts' do
      format = Discover::Artifact.first.format
      Discover::Harvester::PennMuseum.new.harvest do |file|
        described_class.import(file: file)
      end

      expect(Discover::Artifact.first.format).not_to eq format
    end

    it 'does not update unchanged artifacts' do
      attr = Discover::Artifact.second.attributes
      Discover::Harvester::PennMuseum.new.harvest do |file|
        described_class.import(file: file)
      end

      expect(Discover::Artifact.second.attributes).to eq attr
    end
  end
end
