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

      it 'assigns a total count' do
        expect(results.total_count).to eq(1)
      end

      it 'assigns a results url' do
        expect(results.results_url).to eq('https://find.library.upenn.edu/?f%5Baccess_facet%5D%5B%5D=' \
                                            'At+the+library&f%5Blibrary_facet%5D%5B%5D=Special+Collections&' \
                                            'q=%22Menil+%3A+the+Menil+collection%22&search_field=all_fields')
      end

      it 'creates entries' do
        expect(results.first).to be_a(Discover::Entry)
      end

      it 'assigns expected entry title' do
        expect(results.first.title)
          .to contain_exactly 'Menil : the Menil collection'
      end

      it 'assigns expected entry body' do
        expect(results.first.body).to include(author: ['Piano, Renzo.'],
                                              format: ['Book'],
                                              location: ['Fisher Fine Arts Library', 'Special Collections'])
      end

      it 'assigns expected entry identifiers' do
        expect(results.first.identifiers).to include(isbn: %w[9788862640008 8862640005],
                                                     issn: nil,
                                                     oclc_id: ['229431838'])
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
    end

    it 'assigns expected entry title' do
      expect(results.first.title).to eq 'Kronish, Lieb, Weiner, and Hellman LLP Bankruptcy Judges Lawsuit files'
    end

    it 'assigns expected entry body' do
      expect(results.first.body)
        .to include(author: 'Kronish, Lieb, Weiner, and Hellman LLP and National Bankruptcy Archives',
                    format: 'Legal files',
                    location: nil)
    end
  end
end
