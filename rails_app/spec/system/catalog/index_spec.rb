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
        click_on I18n.t('facets.access')
        expect(page).to have_text PennMARC::Access::AT_THE_LIBRARY
      end
    end

    it 'links to chat' do
      chat_url = I18n.t('urls.help.chat', request_url: current_url)
      expect(page).to have_link I18n.t('home.help.connect.chat.title'), href: chat_url
    end

    it 'links to ask' do
      expect(page).to have_link I18n.t('home.help.connect.ask.title'), href: I18n.t('urls.help.ask')
    end

    it 'links to appointment scheduling' do
      expect(page).to have_link I18n.t('home.help.connect.appointment.title'), href: I18n.t('urls.help.appointment')
    end

    it 'links to libraries and hours' do
      expect(page).to have_link I18n.t('home.help.self_service.libraries'), href: I18n.t('urls.help.libraries')
      expect(page).to have_link I18n.t('home.help.self_service.lib_hours'), href: I18n.t('urls.help.lib_hours')
    end
  end

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

  context 'when viewing the recently published facet', skip: 'until new configset with date fields' do
    let(:solr_time) { nil }

    before do
      CatalogController.blacklight_config.default_solr_params = { qt: 'search', NOW: solr_time }
      visit search_catalog_path
    end

    context 'without a recently published record' do
      # the print monograph has a publication date of 1961
      # the electronic journal has a publication date of 1869

      it 'does not show recently published facet' do
        within('#facets') do
          expect(page).not_to have_text I18n.t('facets.recently_published.label')
        end
      end
    end

    context 'with a record published within the last 5 years' do
      # we calculate the last 5 years as the beginning of the year, 4 years ago.

      let(:solr_time) { (Time.new(1965).to_f * 1000).to_i }

      it 'shows recently published for 5 year range' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text I18n.t('facets.recently_published.5_years')
        end
      end

      it 'shows the recently published facet for 10 and 15 year ranges' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text I18n.t('facets.recently_published.10_years')
          expect(page).to have_text I18n.t('facets.recently_published.15_years')
        end
      end

      it 'shows the expected facet count' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text(/\b1\b/, count: 3)
        end
      end
    end

    context 'with a record published within the last 10 years' do
      # we calculate the last 10 years as the beginning of the year, 9 years ago.

      let(:solr_time) { (Time.new(1970).to_f * 1000).to_i }

      it 'does not show recently published facet for 5 year range' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).not_to have_text I18n.t('facets.recently_published.5_years')
        end
      end

      it 'shows recently published facets for 10 and 15 year ranges' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text I18n.t('facets.recently_published.10_years')
          expect(page).to have_text I18n.t('facets.recently_published.15_years')
        end
      end

      it 'shows the expected facet count' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text(/\b1\b/, count: 2)
        end
      end
    end

    context 'with a record published within the last 15 years' do
      # we calculate the last 10 years as the beginning of the year, 14 years ago.

      let(:solr_time) { (Time.new(1975).to_f * 1000).to_i }

      it 'does not show recently published facet for 5 and 10 year ranges' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).not_to have_text I18n.t('facets.recently_published.5_years')
          expect(page).not_to have_text I18n.t('facets.recently_published.10_years')
        end
      end

      it 'shows recently published facets the 15 year range' do
        within('div.blacklight-recently_published_facet') do
          click_on I18n.t('facets.recently_published.label')
          expect(page).to have_text I18n.t('facets.recently_published.15_years')
          expect(page).to have_text(/\b1\b/, count: 1)
        end
      end
    end
  end

  context 'when viewing the recently added facet', skip: 'until new configset with date fields' do
    let(:recently_added_bib) { '9979413181503681' }
    let(:entries) { [create(:physical_entry, mms_id: recently_added_bib)] }
    let(:solr_time) { nil }

    before do
      # added date of "2024-05-30T00:00:00Z"
      SampleIndexer.index 'recently_added.json'

      allow(Inventory::Service).to receive(:full).with(satisfy { |d| d.fetch(:id) == recently_added_bib })
                                                 .and_return(Inventory::Response.new(entries: entries))
      allow(Inventory::Service).to receive(:brief).with(satisfy { |d| d.fetch(:id) == recently_added_bib })
                                                  .and_return(Inventory::Response.new(entries: entries))

      CatalogController.blacklight_config.default_solr_params = { qt: 'search', NOW: solr_time }

      visit search_catalog_path
    end

    context 'without a recently added record' do
      let(:solr_time) { (Time.new(2025).to_f * 1000).to_i }

      it 'does not show the recently added facet' do
        within('#facets') do
          expect(page).not_to have_text I18n.t('facets.recently_added.30_days')
        end
      end
    end

    context 'with a record added in the last 15 days' do
      let(:solr_time) { (Time.new('2024-06-01').to_f * 1000).to_i }

      it 'shows the recently added facet for 15 and 30 day range' do
        within('div.blacklight-recently_added_facet') do
          click_on I18n.t('facets.recently_added.label')
          expect(page).to have_text I18n.t('facets.recently_added.15_days')
          expect(page).to have_text I18n.t('facets.recently_added.30_days')
        end
      end

      it 'shows the recently added facet for 60 and 90 day range' do
        within('div.blacklight-recently_added_facet') do
          click_on I18n.t('facets.recently_added.label')
          expect(page).to have_text I18n.t('facets.recently_added.60_days')
          expect(page).to have_text I18n.t('facets.recently_added.90_days')
        end
      end

      it 'shows the expected facet count' do
        within('div.blacklight-recently_added_facet') do
          click_on I18n.t('facets.recently_added.label')
          expect(page).to have_text(/\b1\b/, count: 4)
        end
      end
    end

    context 'with a record added in the last 90 days' do
      let(:solr_time) { (Time.new('2024-07-31').to_f * 1000).to_i }

      it ' does not show the recently added facet for smaller date ranges' do
        within('div.blacklight-recently_added_facet') do
          click_on I18n.t('facets.recently_added.label')
          expect(page).not_to have_text(/ Within 15|30|60 days/)
        end
      end

      it 'shows the recently added facet for 90 day range' do
        within('div.blacklight-recently_added_facet') do
          click_on I18n.t('facets.recently_added.label')
          expect(page).to have_text I18n.t('facets.recently_added.90_days')
          expect(page).to have_text('1', count: 1)
        end
      end
    end
  end
end
