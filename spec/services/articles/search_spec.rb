# frozen_string_literal: true

describe Articles::Search do
  include Articles::ApiMocks::Search

  let(:query_term) { 'book' }
  let(:search) { described_class.new(query_term: query_term) }
  let(:fixture) { 'book.json' }

  describe '.new' do
    it 'returns an Articles::Search object' do
      expect(search).to be_a described_class
    end

    it 'creates a client object' do
      expect(search.client).to be_a Summon::Service
    end
  end

  describe '#response' do
    it 'makes expected request to client' do
      client = instance_spy('Summon::Service')
      allow(search).to receive(:client).and_return(client)
      search.response
      expect(client).to have_received(:search).with(a_hash_including('s.q' => query_term))
    end

    it 'does not raise error for Summon::Transport::TransportError' do
      client = instance_spy('Summon::Service')
      allow(search).to receive(:client).and_return(client)
      allow(client).to receive(:search).and_raise(Summon::Transport::TransportError)
      expect(search.response).to be_nil
    end
  end

  describe '#documents' do
    context 'when response is successful' do
      before { stub_summon_search_success(query: query_term, fixture: fixture) }

      it 'returns array of documents' do
        expect(search.documents).to all(be_an_instance_of(Articles::Document))
      end

      it 'return expected number of documents' do
        expect(search.documents.count).to be 3
      end

      it 'returns expected documents' do
        expect(search.documents.map(&:title)).to match_array([
                                                               'How to do things with books in victorian britain',
                                                               'BOOK',
                                                               'Reading Beyond the Book: The Social Practices of Contemporary Literary Culture'
                                                             ])
      end
    end

    context 'when response is not successful' do
      before { stub_summon_search_failure(query: query_term) }

      it 'returns nil' do
        expect(search.documents).to be_nil
      end
    end
  end

  describe '#query_string' do
    before { stub_summon_search_success(query: query_term, fixture: fixture) }

    it 'returns actual query string from Summon response' do
      expect(search.query_string).to eq('s.normalized.subjects=f&s.secure=t&s.light=t&s.dailyCatalog=t&s.q=book&s.dym=f&s.ho=t&s.rapido=f&s.hl=f&s.ps=3&s.shortenurl=f&s.ff=ContentType%2Cor%2C1%2C7')
    end
  end

  describe '#success?' do
    context 'when response is successful' do
      before { stub_summon_search_success(query: query_term, fixture: fixture) }

      it 'returns true' do
        expect(search.success?).to be true
      end
    end

    context 'when response is unsuccessful' do
      before { stub_summon_search_failure(query: query_term) }

      it 'returns false' do
        expect(search.success?).to be false
      end
    end
  end

  describe '#facet_manager' do
    context 'when response is successful' do
      before { stub_summon_search_success(query: query_term, fixture: fixture) }

      it 'returns Articles::FacetManager' do
        expect(search.facet_manager).to be_an_instance_of(Articles::FacetManager)
      end
    end

    context 'when response is unsuccessful' do
      before { stub_summon_search_failure(query: query_term) }

      it 'returns nil' do
        expect(search.facet_manager).to be_nil
      end
    end
  end

  describe '.summon_url' do
    before { stub_summon_search_success(query: query_term, fixture: fixture) }

    it 'starts with expected base url' do
      expect(described_class.summon_url(query: search.query_string)).to start_with("https://#{Settings.additional_results_sources.summon.base_url}")
    end

    it 'contains search path' do
      expect(described_class.summon_url(query: search.query_string)).to include('/search')
    end

    it 'contains query' do
      expect(described_class.summon_url(query: search.query_string)).to include("s.q=#{query_term}")
    end
  end
end
