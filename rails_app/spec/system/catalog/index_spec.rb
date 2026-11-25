# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  include Articles::ApiMocks::Search

  include_context 'with print monograph record with 2 physical entries'
  include_context 'with electronic journal record with 4 electronic entries'

  context 'without a search' do
    before { visit search_catalog_path }

    it 'displays facets' do
      within('div.blacklight-access_facet') do
        expect(page).to have_text I18n.t('facets.access')
        expect(page).to have_text PennMARC::Access::AT_THE_LIBRARY
      end
    end
  end

  context 'with an empty search' do
    include_context 'with empty hathi response'

    before { visit search_catalog_path(params: { q: '', search_field: 'all_fields' }) }

    it 'searches and returns all results' do
      expect(page).to have_selector 'article.document', count: 2
    end

    it 'links to the record page' do
      within('article.document-position-1 .documentHeader h3') do
        expect(page).to have_link(href: solr_document_path(electronic_journal_bib))
      end
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

    it 'links to a creator facet search' do
      within("article.document[data-document-id=\"#{print_monograph_bib}\"]") do
        expect(page).to have_link('Bleier, Ruth, 1923-',
                                  href: search_catalog_path({ 'f[creator_facet][]': 'Bleier, Ruth, 1923-' }))
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

  context 'when selecting the Database format facet' do
    include_context 'with electronic database record'

    before { visit search_catalog_path(params: params) }

    context 'when using the regular facet' do
      let(:params) { { f: { format_facet: [PennMARC::Database::DATABASES_FACET_VALUE] } } }

      it 'shows the database-specific facets' do
        within '#facets' do
          expect(page).to have_text I18n.t('facets.databases.category')
          expect(page).to have_text I18n.t('facets.databases.subject')
        end
      end
    end

    context 'when using the advanced search facet' do
      let(:params) { { f_inclusive: { format_facet: [PennMARC::Database::DATABASES_FACET_VALUE] } } }

      it 'shows the database-specific facets' do
        within '#facets' do
          expect(page).to have_text I18n.t('facets.databases.category')
          expect(page).to have_text I18n.t('facets.databases.subject')
        end
      end
    end
  end
end
