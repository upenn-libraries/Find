# frozen_string_literal: true

describe Catalog::BookmarkComponent, type: :components do
  let(:document) { SolrDocument.new(id: '123') }
  let(:component) { described_class.new(document: document, checked: checked) }
  let(:rendered) { render_inline(component) }
  let(:bookmark_label) { rendered.at_css('.toggle-bookmark-label') }

  shared_examples 'an accessible bookmark tooltip' do |translation_key|
    it 'renders the bookmark control with an accessible tooltip label' do
      expected_label = I18n.t(translation_key)

      expect(bookmark_label['data-action']).to eq(described_class::TOOLTIP_REFRESH_ACTION)
      expect(bookmark_label['data-tooltip-content-selector-value']).to eq(described_class::TOOLTIP_CONTENT_SELECTOR)
      expect(bookmark_label['data-controller']).to eq('tooltip')
      expect(bookmark_label['data-bs-title']).to eq(expected_label)
      expect(bookmark_label['aria-label']).to eq(expected_label)
    end
  end

  context 'when the document is not bookmarked' do
    let(:checked) { false }

    include_examples 'an accessible bookmark tooltip', 'blacklight.search.bookmarks.absent'
  end

  context 'when the document is bookmarked' do
    let(:checked) { true }

    include_examples 'an accessible bookmark tooltip', 'blacklight.search.bookmarks.present'
  end
end
