# frozen_string_literal: true

describe Articles::Document do
  include Articles::ApiMocks::Search

  let(:documents) { Articles::Search.new(query_term: 'book').documents }
  let(:doc) { documents.first }
  let(:doc_no_author_no_fulltext) { documents.second }
  let(:doc_w_subtitle_no_date) { documents.last }

  before do
    stub_summon_search_success(query: 'book', fixture: 'book.json')
  end

  describe '#title' do
    context 'when title does not have a subtitle' do
      it 'returns title' do
        expect(doc.title).to eq('How to do things with books in victorian britain')
      end
    end

    context 'when title has a subtitle' do
      it 'appends subtitle to title' do
        expected_title = 'Reading Beyond the Book: The Social Practices of Contemporary Literary Culture'
        expect(doc_w_subtitle_no_date.title).to eq(expected_title)
      end
    end
  end

  describe '#proxy_link' do
    it 'returns the proxy link' do
      expect(doc.proxy_link).to eq(I18n.t('urls.external_services.proxy', url: doc.link))
    end
  end

  describe '#fulltext_online' do
    context 'when document is fulltext' do
      it 'returns Full Text Online string' do
        expect(doc.fulltext_online).to eq('Full text online')
      end
    end

    context 'when document is not fulltext' do
      it 'returns nil' do
        expect(doc_no_author_no_fulltext.fulltext_online).to be_nil
      end
    end
  end

  describe '#authors_list' do
    context 'when authors are present' do
      it 'returns a string' do
        expect(doc.authors.list).to be_a(String)
      end
    end

    context 'when authors are not present' do
      it 'does not respond to the list method' do
        expect(doc_no_author_no_fulltext.authors).not_to respond_to(:list)
      end
    end
  end

  describe 'publication_year' do
    context 'when publication date is present' do
      it 'returns the year as a string' do
        expect(doc.publication_year).to eq('2012')
      end
    end

    context 'when publication date is not present' do
      it 'returns nil' do
        expect(doc_w_subtitle_no_date.publication_year).to be_nil
      end
    end
  end
end
