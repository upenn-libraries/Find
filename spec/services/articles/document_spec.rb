# frozen_string_literal: true

describe Articles::Document do
  include Articles::ApiMocks::Search

  let(:documents) { Articles::Search.new(query_term: 'book').documents }

  before do
    stub_summon_search_success(query: 'book', fixture: 'articles/book.json')
  end

  describe '#title' do
    context 'when title does not have a subtitle' do
      it 'return title'
    end

    context 'when title has a subtitle' do
      it 'appends subtitle to title'
    end
  end

  describe '#fulltext_online' do
    context 'when document is fulltext' do
      it 'return true'
    end

    context 'when document is not fulltext'
  end

  describe '#authors_list' do
    context 'when authors are present'

    context 'when authors are not present'
  end

  describe 'publication_year' do
    context 'when publication date is present'

    context 'when publication date is not present'
  end

  it 'has the expected values' do
    expect(articles_document.title).to eq 'How to do things with books in victorian britain'
  end
end
