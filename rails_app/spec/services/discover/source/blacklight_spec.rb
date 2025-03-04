# frozen_string_literal: true

describe Discover::Source::Blacklight do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  shared_examples 'a blacklight source' do |source_name|
    let(:source) { described_class.new(source: source_name) }
    let(:query) { { q: search_term } }
    let(:results) { source.results(query: query[:q]) }

    before do
      stub_blacklight_response(
        source: source_name,
        query: "Discover::Configuration::Blacklight::#{source_name.camelize}::QUERY_PARAMS"
                 .safe_constantize.merge(query),
        response: json_fixture("#{source_name}_response", :discover)
      )
    end

    it 'returns a Results object' do
      expect(results).to be_a(Discover::Results)
    end

    it 'creates entries' do
      expect(results.first).to be_a(Discover::Entry)
    end
  end

  context 'with Find source' do
    let(:search_term) { '"Menil : the Menil collection"' }

    include_examples 'a blacklight source', 'find'

    it 'assigns a total count' do
      expect(results.total_count).to eq(1)
    end

    it 'assigns a results url' do
      expect(results.results_url).to eq('https://find.library.upenn.edu/?f%5Baccess_facet%5D%5B%5D=' \
                                          'At+the+library&f%5Blibrary_facet%5D%5B%5D=Special+Collections&' \
                                          'q=%22Menil+%3A+the+Menil+collection%22&search_field=all_fields')
    end

    it 'assigns expected entry title' do
      expect(results.first.title).to contain_exactly 'Menil : the Menil collection'
    end

    it 'assigns expected entry body' do
      expect(results.first.body).to include(author: ['Piano, Renzo.'],
                                            format: ['Book'],
                                            location: ['Fisher Fine Arts Library', 'Special Collections'],
                                            publication: ["[Genova] : Fondazione Renzo Piano ; [Place of publication \
                                not identified] : SOFP, Società operativa Fondazione Piano srl, [2007]".squish],
                                            abstract: [])
    end

    it 'assigns expected entry identifiers' do
      expect(results.first.identifiers).to include(isbn: %w[9788862640008 8862640005],
                                                   issn: nil,
                                                   oclc_id: ['229431838'])
    end

    it 'assigns expected thumbnail_url' do
      expect(results.first.thumbnail_url).to eq 'https://colenda.library.upenn.edu/items/ark:/81431/p3th8cb15/thumbnail'
    end
  end

  context 'with Finding Aids source' do
    let(:search_term) { 'shainswit' }

    include_examples 'a blacklight source', 'finding_aids'

    it 'assigns a total count' do
      expect(results.total_count).to eq(1)
    end

    it 'assigns a results url' do
      expect(results.results_url).to eq('https://findingaids.library.upenn.edu/' \
                                          '?f%5Brecord_source%5D%5B%5D=upenn&q=shainswit')
    end

    it 'assigns expected entry title' do
      expect(results.first.title)
        .to contain_exactly 'Kronish, Lieb, Weiner, and Hellman LLP Bankruptcy Judges Lawsuit files'
    end

    it 'assigns expected entry body' do
      expect(results.first.body).to include(:author, :format, :location, :publication, :abstract)
    end

    it 'assigns expected author' do
      expect(results.first.body[:author]).to eq ['Kronish, Lieb, Weiner, and Hellman LLP',
                                                 'National Bankruptcy Archives']
    end

    it 'assigns expected format' do
      expect(results.first.body[:format]).to eq ['Legal files']
    end

    it 'assigns expected location' do
      expect(results.first.body[:location]).to eq ['University of Pennsylvania: Biddle Law Library']
    end

    it 'assigns expected publication' do
      expect(results.first.body[:publication]).to eq []
    end

    it 'assigns expected abstract' do
      expect(results.first.body[:abstract].first).to start_with('On July 11, 1984, William Foley')
    end

    it 'assigns expected thumbnail_url' do
      expect(results.first.thumbnail_url).to be nil
    end

    it 'properly un-encodes characters in body fields' do
      expect(results.first.body[:abstract].first).to include '("Administrative Office")'
    end
  end

  describe '#blacklight?' do
    it 'returns true' do
      expect(described_class.new(source: 'find').blacklight?).to be true
    end
  end

  describe '#pse?' do
    it 'returns false' do
      expect(described_class.new(source: 'find').pse?).to be false
    end
  end
end
