# frozen_string_literal: true

describe Discover::Source::PSE do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  shared_examples 'a PSE source' do |source_name|
    let(:source) { described_class.new(source: source_name) }
    let(:query) { { q: search_term } }
    let(:results) { source.results(query: query[:q]) }

    before do
      stub_pse_response(
        query: "Discover::Configuration::PSE::#{source_name.camelize}::QUERY_PARAMS"
                 .safe_constantize.merge(query),
        response: json_fixture("#{source_name}_response", :discover)
      )
    end

    it 'returns a Results object' do
      expect(results).to be_a(Discover::Results)
    end
  end

  context 'with Museum source' do
    let(:search_term) { 'B13186' }

    include_examples 'a PSE source', 'museum'

    it 'assigns a total count' do
      expect(results.total_count).to eq(1)
    end

    it 'assigns a results url' do
      expect(results.results_url).to eq('https://www.penn.museum/collections/search.php?term=B13186')
    end

    it 'assigns exptected entry title' do
      expect(results.first.title).to contain_exactly('Hebrew Bowl - B13186 | Collections - Penn Museum')
    end

    it 'assigns expected entry body' do
      expect(results.first.body).to include(description: ['Penn Museum Object B13186 - Hebrew Bowl.'])
    end
  end

  describe '#blacklight?' do
    it 'returns false' do
      expect(described_class.new(source: 'museum').blacklight?).to be false
    end
  end

  describe '#pse?' do
    it 'returns true' do
      expect(described_class.new(source: 'museum').pse?).to be true
    end
  end
end
