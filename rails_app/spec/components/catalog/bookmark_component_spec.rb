# frozen_string_literal: true

describe Catalog::BookmarkComponent, type: :components do
  let(:document) { SolrDocument.new(id: '123') }
  let(:component) { described_class.new(document: document, checked: checked) }
  let(:rendered) { render_inline(component) }
  let(:bookmark_label) { rendered.at_css('.toggle-bookmark-label') }

  context 'when the document is not bookmarked' do
    let(:checked) { false }

    it 'renders the bookmark control with absent label' do
      expect(bookmark_label['data-bs-title']).to eq(I18n.t('blacklight.search.bookmarks.absent'))
    end
  end

  context 'when the document is bookmarked' do
    let(:checked) { true }

    it 'renders the bookmark control with present label' do
      expect(bookmark_label['data-bs-title']).to eq(I18n.t('blacklight.search.bookmarks.present'))
    end
  end
end
