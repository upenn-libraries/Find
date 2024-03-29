# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  # Shared example to be able to test features across different types of records.
  shared_examples 'core show page features' do
    let(:params) { {} }

    before { visit solr_document_path(mms_id, params: params) }

    it 'shows document' do
      expect(page).to have_selector 'div.document-main-section'
    end

    it 'shows some item metadata' do
      expect(page).to have_selector 'dd.blacklight-format_facet'
    end

    it 'displays all entries in navigation' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item', count: entries.count)
        expect(page).to have_selector('button.inventory-item.active', count: 1)
      end
    end

    it 'defaults to the first holding in navigation' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item.active', text: entries.first.description)
      end
    end

    it 'defaults to the first holding in tab pane' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_selector('.tab-pane', count: 1)
        expect(page).to have_selector('#inventory-0')
      end
    end

    it 'displays correct information in tab page' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_content entries.first.description
        expect(page).to have_content entries.first.coverage_statement
      end
    end

    context 'when holding_id is provided in params' do
      let(:params) { { hld_id: entries.second.id } }

      it 'displays all entries in navigation' do
        within('#inventory-pills-tab') do
          expect(page).to have_selector('button.inventory-item', count: entries.count)
          expect(page).to have_selector('button.inventory-item.active', count: 1)
        end
      end

      it 'selects the second holding in the navigation' do
        within('#inventory-pills-tab') do
          expect(page).to have_selector('button.inventory-item.active', text: entries.second.description)
        end
      end

      it 'display the second holding in the tab pane' do
        within('#inventory-pills-tabContent') do
          expect(page).to have_selector('.tab-pane', count: 1)
          expect(page).to have_selector('#inventory-1')
        end
      end

      it 'display data for second holding in tab pane' do
        within('#inventory-pills-tabContent') do
          expect(page).to have_content entries.second.description
          expect(page).to have_content entries.second.coverage_statement
        end
      end
    end

    context 'when clicking on a holding' do
      before do
        click_button entries.second.description
      end

      it 'selects the holding in the navigation' do
        within('#inventory-pills-tab') do
          expect(page).to have_selector('button.inventory-item.active', text: entries.second.description)
        end
      end

      it 'displays the selected holding in tab pane' do
        within('#inventory-pills-tabContent') do
          expect(page).to have_selector('.tab-pane', count: 1)
          expect(page).to have_selector('#inventory-1')
        end
      end

      it 'display data for second holding in tab pane' do
        within('#inventory-pills-tabContent') do
          expect(page).to have_content entries.second.description
          expect(page).to have_content entries.second.coverage_statement
        end
      end
    end
  end

  # Record with 4 electronic holdings
  context 'when viewing a electronic journal record' do
    include_context 'with electronic journal record'

    let(:mms_id) { electronic_journal_bib }
    let(:entries) { electronic_journal_entries }

    include_examples 'core show page features'
  end

  # Record with 2 physical holdings
  context 'when viewing a print monograph record' do
    include_context 'with print monograph record'

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    include_examples 'core show page features'
  end

  context 'when interacting with show tools' do
    include_context 'with electronic journal record'

    let(:mms_id) { electronic_journal_bib }

    before { visit solr_document_path(mms_id) }

    context 'when a user is signed in' do
      before do
        sign_in create(:user)
        visit solr_document_path(mms_id)
      end

      it 'displays a link to email the record' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link 'Email', href: "/catalog/#{mms_id}/email"
      end
    end

    context 'when a user is not signed in' do
      it 'displays a link to login' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link(I18n.t('blacklight.tools.login_for_email'), href: "#{login_path}?id=#{mms_id}")
      end
    end

    it 'displays Staff view link' do
      click_on I18n.t('blacklight.tools.title')
      expect(page).to have_link I18n.t('blacklight.tools.staff_view'), href: "/catalog/#{mms_id}/staff_view"
    end
  end
end
