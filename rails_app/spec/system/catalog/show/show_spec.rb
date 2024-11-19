# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  context 'when the Alma API calls time out' do
    include_context 'with electronic database record having a resource link entry but fails to retrieve Alma holdings'

    before do
      visit solr_document_path(electronic_db_bib)
    end

    it 'renders the page with appropriate message' do
      expect(page).to have_text I18n.t('inventory.incomplete_inventory')
    end

    it 'still shows any resource link holdings' do
      expect(page).to have_link 'Connect to resource', href: 'http://hdl.library.upenn.edu/1017/126017'
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
                                                    component: Catalog::FacetLinkComponent
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
      include_context 'with a conference proceedings record with 1 physical holding'

      before do
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

  context 'when linking to a fielded search' do
    context 'with a standardized title' do
      include_context 'with electronic journal record with 4 electronic entries'

      before do
        visit(solr_document_path(electronic_journal_bib))
      end

      it 'links to a title fielded search' do
        within('.col-md-9.blacklight-title_standardized_show') do
          expect(page).to have_link('Nature (Online)', href: search_catalog_path(
            { clause: { '2': { field: 'title_search', query: '"Nature (Online)"' } } }
          ))
        end
      end
    end

    context 'with a series title' do
      let(:show_value) do
        'Report (Expanded Program of Technical Assistance (Food and Agriculture Organization of the United ' \
          'Nations)) ; C77.'
      end

      let(:query_value) do
        '"Report (Expanded Program of Technical Assistance (Food and Agriculture Organization of the United ' \
          'Nations))"'
      end

      include_context 'with a conference proceedings record with 1 physical holding'

      before do
        visit(solr_document_path(conference_bib))
      end

      it 'links to a title fielded search' do
        within('.col-md-9.blacklight-series_show') do
          expect(page).to have_link(show_value, href: search_catalog_path(
            { clause: { '2': { field: 'title_search', query: query_value } } }
          ))
        end
      end
    end
  end
end
