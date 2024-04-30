# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  include Articles::ApiMocks::Search

  include_context 'with print monograph record with 2 physical entries'
  include_context 'with electronic journal record with 4 electronic entries'

  context 'with an empty search' do
    before { visit search_catalog_path(params: { q: '', search_field: 'all_fields' }) }

    it 'displays facets' do
      within('div.blacklight-access_facet') do
        expect(page).to have_text I18n.t('facets.access')
        click_on I18n.t('facets.access')
        expect(page).to have_text PennMARC::Access::AT_THE_LIBRARY
      end
    end

    it 'searches and returns all results' do
      expect(page).to have_selector 'article.document', count: 2
    end

    it 'opens a result page when clicking on a record' do
      within('article.document-position-1 .documentHeader') { find('a').click }
      expect(page).to have_selector 'section.show-document'
    end

    it 'displays 3 inventory entries for electronic record' do
      within("article.document[data-document-id=\"#{electronic_journal_bib}\"] .holdings") do
        expect(page).to have_selector 'li.holding__item', count: 3
      end
    end

    it 'displays correct titles for all electronic entries' do
      within("article.document[data-document-id=\"#{electronic_journal_bib}\"] .holdings") do
        electronic_journal_entries.first(3).each do |e|
          expect(page).to have_text(e.description)
        end
      end
    end

    it 'displays 2 inventory entries for physical record' do
      within("article.document[data-document-id=\"#{print_monograph_bib}\"] .holdings") do
        expect(page).to have_selector 'li.holding__item', count: 2
      end
    end

    it 'displays correct titles for all physical entries' do
      within("article.document[data-document-id=\"#{print_monograph_bib}\"] .holdings") do
        print_monograph_entries.each do |e|
          expect(page).to have_text(e.description)
        end
      end
    end
  end

  context 'with search term' do
    before do
      stub_summon_search_success(query: 'nature', fixture: 'book.json')
      visit search_catalog_path(params: { q: 'nature', search_field: 'all_fields' })
    end

    it 'displays one search result' do
      expect(page).to have_selector 'article.document', count: 1
    end
  end
end
