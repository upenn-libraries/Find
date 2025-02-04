# frozen_string_literal: true

describe Discover::Source::Libraries do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  let(:source) { described_class.new }
  let(:results) { source.results(query: 'billiards') }
  let(:query) do
    { 'q' => 'billiards',
      'f[access_facet][]' => 'At the library',
      'f[library_facet][]' => 'Special Collections',
      'search_field' => 'all_fields' }
  end

  describe '#results' do
    before { stub_libraries_request(query: query, response: json_fixture('libraries_response', :discover)) }

    it 'returns a Results object' do
      expect(results).to be_a(Discover::Results)
    end

    it 'creates entries' do
      expect(results.first).to be_a(Discover::Entry)
      expect(results.count).to eq 10
    end

    it 'returns expected results' do
      expect(results.first.title).to eq 'Mark Twain on bowling & billiards : a chapter from the autobiography.'
    end
  end
end
