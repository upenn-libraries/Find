# frozen_string_literal: true

require 'system_helper'

describe 'Catalog show page with a Physical record' do
  context 'when viewing a print monograph record' do
    include_context 'with print monograph record with 2 physical entries'

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    include_examples 'core show page features'

    it 'does not display the search input' do
      expect(page).not_to have_selector '.search-list__input'
    end

    context 'when additional holding details can be retrieved from Alma' do
      it 'displays additional details/notes' do
        within('#inventory-0') do
          expect(page).to have_selector '.inventory-item__notes',
                                        text: 'First note Second note Third note 2-First note 2-Second note'
        end
      end
    end
  end

  context 'when viewing a print monograph record with an alternate title' do
    include_context 'with print monograph with an entry with an alternate title'

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    before do
      visit solr_document_path(mms_id)
      click_button entries.first.description
    end

    it 'displays the title' do
      within('.document-main-section') do
        expect(page).to have_selector '.record-title'
      end
    end

    it 'displays the alternate title' do
      within('.record-title') do
        expect(page).to have_selector '.record-alternate-title'
      end
    end
  end

  context 'when a record has many entries' do
    include_context 'with print monograph record with 9 physical entries'

    let(:mms_id) { print_monograph_bib }

    before { visit solr_document_path(mms_id) }

    it 'shows the search input' do
      within('.search-list') do
        expect(page).to have_selector '.search-list__input'
      end
    end

    it 'filters the holdings' do
      within('[data-controller="search-list"]') do
        fill_in 'Search this list', with: 'copy 0'
        expect(page).to have_selector('.inventory-item', count: 1)
      end
    end
  end

  context 'when a record has entries in a temporary location' do
    include_context 'with print monograph record with an entry in a temp location'

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    before { visit solr_document_path(mms_id) }

    it 'shows two inventory entries' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item', count: entries.count)
        expect(page).to have_selector('button.inventory-item.active', count: 1)
      end
    end

    it 'shows the first entry on page load' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_content entries.first.description
        expect(page).to have_content entries.first.coverage_statement
      end
    end

    it 'loads the second entry if clicked' do
      click_button entries.second.description
      within('#inventory-pills-tabContent') do
        expect(page).to have_content entries.second.description
        expect(page).to have_content entries.second.coverage_statement
      end
    end
  end
end
