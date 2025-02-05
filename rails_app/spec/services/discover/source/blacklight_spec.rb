# frozen_string_literal: true

describe Discover::Source::Blacklight do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  context 'with Find source' do
    let(:source) { described_class.new(source: 'find') }
    let(:query) { { q: 'billiards' } }
    let(:results) { source.results(query: query[:q]) }

    describe '#results' do
      before do
        stub_find_request(query: Discover::Configuration::Blacklight::Find::QUERY_PARAMS.merge(query),
                          response: json_fixture('find_response', :discover))
      end

      it 'returns a Results object' do
        expect(results).to be_a(Discover::Results)
      end

      it 'creates entries' do
        expect(results.first).to be_a(Discover::Entry)
        expect(results.count).to eq 10
      end

      it 'assigns expected entry title' do
        expect(results.first.title).to eq 'Mark Twain on bowling & billiards : a chapter from the autobiography.'
      end

      it 'assigns expected entry body' do
        expect(results.first.body).to include(author: 'Twain, Mark, 1835-1910, author.', format: 'Book')
      end
    end
  end

  context 'with Finding Aids source' do
    let(:source) { described_class.new(source: 'finding_aids') }
    let(:query) { { q: 'ballads' } }
    let(:results) { source.results(query: query[:q]) }

    before do
      stub_finding_aids_request(query: Discover::Configuration::Blacklight::FindingAids::QUERY_PARAMS.merge(query),
                                response: json_fixture('finding_aids_response', :discover))
    end

    it 'returns a Results object' do
      expect(results).to be_a(Discover::Results)
    end

    it 'creates entries' do
      expect(results.first).to be_a(Discover::Entry)
      expect(results.count).to eq 10
    end

    it 'assigns expected entry title' do
      expect(results.first.title).to eq 'American and British ballads'
    end

    it 'assigns expected entry body' do
      expect(results.first.body).to include(author: nil, format: nil)
    end
  end
end
