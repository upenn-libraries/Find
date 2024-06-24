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

    it 'updates the url with holding ID' do
      expect(page).to have_current_path(solr_document_path(mms_id, params: { hld_id: entries.first.id }))
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

      it 'displays data for second holding in tab pane' do
        within('#inventory-pills-tabContent') do
          expect(page).to have_content entries.second.description
          expect(page).to have_content entries.second.coverage_statement
        end
      end

      it 'updates the url with holding ID' do
        expect(page).to have_current_path(solr_document_path(mms_id, params: { hld_id: entries.second.id }))
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
        expect(page).to have_selector 'select#item_id'
      end

      it 'shows request options when an item is selected' do
        find('select#item_id').find(:option, items.first.description).select_option
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

      it 'shows the schedule visit button with aeon href' do
        within('.request-buttons') do
          aeon_link = find_link I18n.t('requests.form.buttons.aeon')
          expect(aeon_link[:href]).to start_with(Settings.aeon.requesting_url)
          expect(aeon_link[:href]).to include(CGI.escape(item.bib_data['title']))
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

    context 'with an item that is unavailable' do
      let(:item) { build :item, :not_checkoutable }

      before do
        allow(Inventory::Service::Physical).to receive(:items).and_return([item])
        allow(Inventory::Service::Physical).to receive(:item).and_return(item)
        find('details.fulfillment > summary').click
      end

      it 'shows the unavailable message' do
        within('.fulfillment__container') do
          expect(page).to have_selector '.js_unavailable'
        end
      end

      it 'shows the unavailable button with open params' do
        within('.request-buttons') do
          button = find_link I18n.t('requests.form.buttons.unavailable')
          expect(button[:href]).to include(ill_new_request_path)
          expect(button[:href]).to include(CGI.escape(item.bib_data['title']))
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

      # rubocop:disable RSpec/ExampleLength
      it 'properly sends an email' do
        expect {
          click_on I18n.t('blacklight.tools.title')
          click_on I18n.t('blacklight.tools.email')
          fill_in :to, with: 'patron@upenn.edu'
          click_on I18n.t('blacklight.email.form.submit')
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      # rubocop:enable RSpec/ExampleLength
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

  context 'when linking to a facet search' do
    context 'when no matching facet is found' do
      include_context 'with print monograph record with 2 physical entries'

      before do
        CatalogController.configure_blacklight do |config|
          config.add_show_field :subject_test_show, values: ->(_, _, _) { ['Dogs.'] },
                                                    component: Find::FacetLinkComponent
        end

        visit(solr_document_path(print_monograph_bib))
      end

      it 'shows the display value without a link to facet search' do
        within('.col-md-9.blacklight-subject_test_show') do
          expect(page).to have_text('Dogs.')
          expect(page).not_to have_link('Dogs.')
        end
      end
    end

    context 'when viewing main creator' do
      include_context 'with print monograph record with 2 physical entries'

      before { visit(solr_document_path(print_monograph_bib)) }

      it 'links to creator facet search' do
        within('.col-md-9.blacklight-creator_show') do
          expect(page).to have_link('Bleier, Ruth, 1923-',
                                    href: search_catalog_path({ 'f[creator_facet][]': 'Bleier, Ruth, 1923-' }))
        end
      end
    end

    context 'when viewing subjects' do
      include_context 'with print monograph record with 2 physical entries'

      before { visit(solr_document_path(print_monograph_bib)) }

      it 'links to a subject facet search' do
        within('.col-md-9.blacklight-subject_show') do
          expect(page).to have_link 'Cats.', href: search_catalog_path({ 'f[subject_facet][]': 'Cats' })
          expect(page).to have_link 'Hypothalamus.', href: search_catalog_path({ 'f[subject_facet][]': 'Hypothalamus' })
        end
      end
    end

    context 'when viewing medical subjects' do
      include_context 'with print monograph record with 2 physical entries'

      before { visit(solr_document_path(print_monograph_bib)) }

      it 'links to a subject facet search' do
        within('.col-md-9.blacklight-subject_medical_show') do
          expect(page).to have_link 'Cats.', href: search_catalog_path({ 'f[subject_facet][]': 'Cats' })
          expect(page).to have_link 'Hypothalamus.', href: search_catalog_path({ 'f[subject_facet][]': 'Hypothalamus' })
        end
      end
    end

    context 'when viewing contributors' do
      include_context 'with electronic database record'

      before { visit(solr_document_path(electronic_db_bib)) }

      it 'links to a creator facet search' do
        within('.col-md-9.blacklight-creator_contributor_show') do
          expect(page).to have_link('Geo Abstracts, Ltd.',
                                    href: search_catalog_path({ 'f[creator_facet][]': 'Geo Abstracts, Ltd' }))
        end
      end
    end

    context 'when viewing a conference' do
      let(:conference_bib) { '9978940183503681' }
      let(:conference_entries) do
        [create(:physical_entry, mms_id: conference_bib, availability: 'available', call_number: 'U6 .A313',
                                 inventory_type: 'physical')]
      end

      before do
        SampleIndexer.index 'conference.json'

        allow(Inventory::Service).to receive(:full).with(satisfy { |d| d.fetch(:id) == conference_bib })
                                                   .and_return(Inventory::Response.new(entries: conference_entries))
        allow(Inventory::Service).to receive(:brief).with(satisfy { |d| d.fetch(:id) == conference_bib })
                                                    .and_return(Inventory::Response.new(entries: conference_entries))
        visit(solr_document_path(conference_bib))
      end

      it 'links to a creator facet search' do
        show = 'Food and Agriculture Organization of the United Nations (Conference : , 19th : 1977 : Rome, Italy)'
        facet = 'Food and Agriculture Organization of the United Nations (Conference : , 19th : Rome, Italy)'
        within('.col-md-9.blacklight-creator_conference_detail_show') do
          expect(page).to have_link(show, href: search_catalog_path({ 'f[creator_facet][]': facet }))
        end
      end
    end
  end
end
