# frozen_string_literal: true

describe Articles::FacetManager do
  include Articles::ApiMocks::Search

  let(:search) { Articles::Search.new(query_term: 'book') }
  let(:facet_manager) { search.facet_manager }
  let(:original_query) { search.query_string }

  describe '.new' do
    before { stub_summon_search_success(query: 'book', fixture: 'book.json') }

    it 'returns an Articles::FacetManager object' do
      expect(facet_manager).to be_a described_class
    end
  end

  describe '#counts' do
    let(:format_counts) { facet_manager.counts['ContentType'] }
    let(:count_labels) do
      ['Book Review', 'Book / eBook', 'Newspaper Article',
       'Journal Article', 'Book Chapter', 'Magazine Article']
    end

    before { stub_summon_search_success(query: 'book', fixture: 'book.json') }

    it 'has expected number of facet counts for a given facet field' do
      expect(format_counts.count).to eq(6)
    end

    it 'returns expected facet count labels for a given facet field' do
      expect(format_counts.first[:label]).to eq(count_labels.first)
    end

    it 'returns expected facet count doc counts for a given facet field' do
      expect(format_counts.first[:doc_count]).to eq(12_865_640)
    end

    it 'returns expected facet count urls for a given facet field' do
      second_count_query = "&s.fvf=ContentType,#{CGI.escape(count_labels.second)},f"

      expect(format_counts.second[:url]).to eq(
        Articles::Search.summon_url(query: "#{original_query}#{second_count_query}")
      )
    end
  end
end
