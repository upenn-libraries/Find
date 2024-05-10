# frozen_string_literal: true

describe Articles::AuthorsList do
  include Articles::ApiMocks::Search

  let(:documents) { Articles::Search.new(query_term: 'bernstein').documents }
  let(:four_authors) { documents.first.authors }
  let(:three_authors) { documents.second.authors }
  let(:two_authors) { documents.last.authors }

  before do
    stub_summon_search_success(query: 'bernstein', fixture: 'authors_list_variants.json')
  end

  describe '.new' do
    it 'returns an Articles::AuthorsList object' do
      expect(four_authors).to be_a(described_class)
    end

    it 'builds an authors list' do
      expect(four_authors.list).to be_a(String)
    end
  end

  describe '#list' do
    context 'when there are two authors' do
      it 'returns author names in first last format separated by "and"' do
        expect(two_authors.list).to eq('Rebecca Schmid and John Doe')
      end
    end

    context 'when there are three authors' do
      it 'returns a comma-separated list of author names in first last format' do
        expect(three_authors.list).to eq('René L Schilling, Renming Song, and Zoran Vondracek')
      end
    end

    context 'when there are four authors' do
      it 'returns first two author names in first last format followed by "et al."' do
        expect(four_authors.list).to eq('Martin Fischer, Howard W Ashcraft, et al.')
      end
    end
  end
end
