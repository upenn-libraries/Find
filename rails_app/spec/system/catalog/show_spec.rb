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
    include_context 'with electronic journal record with 4 electronic entries'

    let(:mms_id) { electronic_journal_bib }
    let(:entries) { electronic_journal_entries }

    include_examples 'core show page features'

    context 'when additional details/notes can be retrieved from Alma' do
      before do
        visit solr_document_path(mms_id)
        click_button entries.second.description # second entry has additional details
      end

      it 'displays additional details/notes' do
        within('#inventory-1') do
          expect(page).to have_selector '.inventory-item__notes',
                                        text: 'In this database, you may need to navigate to view your article.'
        end
      end
    end
  end

  # Record with 2 physical holdings
  context 'when viewing a print monograph record' do
    include_context 'with print monograph record with 2 physical entries'

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    include_examples 'core show page features'
  end

  # Request options for a physical holding
  context 'when requesting a physical holding' do
    include_context 'with print monograph record with 2 physical entries'
    include_context 'with mock alma_record on user'

    let(:user) { create(:user) }
    let(:alma_user_data) { { user_group: { 'value' => 'undergrad', 'desc' => 'undergraduate' } } }

    let(:mms_id) { print_monograph_bib }
    let(:entries) { print_monograph_entries }

    before do
      sign_in user
      visit solr_document_path(mms_id)
      click_button entries.second.description
    end

    it 'shows the button to request the item' do
      within('details.fulfillment') do
        expect(page).to have_selector 'summary', text: I18n.t('requests.form.request_item')
      end
    end

    context 'with a holding that has one checkoutable item' do
      let(:item) { build :item, :checkoutable }

      before do
        allow(Inventory::Service::Physical).to receive(:items).and_return([item])
        allow(Inventory::Service::Physical).to receive(:item).and_return(item)
        find('details.fulfillment > summary').click
      end

      it 'automatically shows request options when there is a single item' do
        within('.fulfillment__container') do
          expect(page).to have_selector '.js_radio-options'
        end
      end

      it 'selects the first option' do
        within('.js_radio-options') do
          expect(first('input[type="radio"]')[:checked]).to be true
        end
      end

      it 'shows the right button' do
        within('.request-buttons') do
          expect(page).to have_link I18n.t('requests.form.buttons.scan')
        end
      end
    end

    context 'with a holding that has multiple checkoutable items' do
      let(:items) { build_list :item, 2, :checkoutable }

      before do
        allow(Inventory::Service::Physical).to receive(:items).and_return(items)
        allow(Inventory::Service::Physical).to receive(:item).and_return(items.first)
        find('details.fulfillment > summary').click
      end

      it 'shows the item dropdown when there are more than one item' do
        expect(page).to have_selector 'select#item_pid'
      end

      it 'shows request options when an item is selected' do
        find('select#item_pid').find(:option, items.first.description).select_option
        expect(page).to have_selector '.js_radio-options'
      end
    end

    context 'with an aeon requestable item' do
      let(:item) { build :item, :aeon_requestable }

      before do
        allow(Inventory::Service::Physical).to receive(:items).and_return([item])
        allow(Inventory::Service::Physical).to receive(:item).and_return(item)
        find('details.fulfillment > summary').click
      end

      it 'shows the aeon request options' do
        within('.fulfillment__container') do
          expect(page).to have_selector '.js_aeon'
        end
      end

      it 'shows the right button' do
        within('.request-buttons') do
          expect(page).to have_link I18n.t('requests.form.buttons.aeon')
        end
      end
    end

    context 'with an item at the archives' do
      let(:item) { build :item, :at_archives }

      before do
        allow(Inventory::Service::Physical).to receive(:items).and_return([item])
        allow(Inventory::Service::Physical).to receive(:item).and_return(item)
        find('details.fulfillment > summary').click
      end

      it 'shows the archives request options' do
        within('.fulfillment__container') do
          expect(page).to have_selector '.js_archives'
        end
      end
    end
  end

  context 'when interacting with show tools' do
    include_context 'with electronic journal record with 4 electronic entries'

    let(:mms_id) { electronic_journal_bib }

    before { visit solr_document_path(mms_id) }

    context 'when a user is signed in' do
      before do
        sign_in create(:user)
        visit solr_document_path(mms_id)
      end

      it 'displays a link to email the record' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link 'Email', href: email_solr_document_path(mms_id)
      end
    end

    context 'when a user is not signed in' do
      it 'displays a link to login' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link(I18n.t('blacklight.tools.login_for_email'), href: login_path(id: mms_id))
      end
    end

    it 'displays Staff view link' do
      click_on I18n.t('blacklight.tools.title')
      expect(page).to have_link I18n.t('blacklight.tools.staff_view'), href: staff_view_solr_document_path(mms_id)
    end
  end

  context 'when viewing inventory navigation pane' do
    include_context 'with print monograph record with 2 physical entries'

    before { visit(solr_document_path(print_monograph_bib)) }

    it 'applies the correct class when holding is available' do
      expect(page).to have_button(class: 'inventory-item__availability--easy')
    end

    context 'when holdings have an availability status other than "available"' do
      include_context 'with print monograph record with 2 physical entries' do
        let(:print_monograph_entries) do
          [create(:physical_entry, mms_id: print_monograph_bib, availability: 'unavailable', holding_id: '1234',
                                   call_number: 'Oversize QL937 B646 1961', holding_info: 'first copy',
                                   location_code: 'veteresov', inventory_type: 'physical'),
           create(:physical_entry, mms_id: print_monograph_bib, availability: 'check holdings', holding_id: '5678',
                                   call_number: 'Oversize QL937 B646 1961 copy 2', holding_info: 'second copy',
                                   location_code: 'veteresov', inventory_type: 'physical')]
        end
      end

      it 'applies the correct class when availability status is "unavailable"' do
        within('#inventory-pills-tab') do
          expect(page).to have_button(class: 'inventory-item__availability--difficult')
        end
      end

      it 'applies the correct class when availability status is "check holdings"' do
        within('#inventory-pills-tab') do
          expect(page).to have_button(class: 'inventory-item__availability')
        end
      end
    end
  end
end
