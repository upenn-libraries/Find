# frozen_string_literal: true

require 'system_helper'

describe 'Discover Penn page' do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  before do
    visit discover_path
  end

  # TODO: replace this spec with more substantive ones and meaningful content is added
  it 'includes the site title' do
    expect(page).to have_text I18n.t('discover.site_name')
  end

  context 'when submitting a query' do
    let(:query) { { q: 'test' } }

    before do
      stub_all_responses(query: query)
      fill_in 'q', with: query[:q]
      click_on 'Search'
    end

    context 'with libraries results' do
      it 'displays expected title' do
        within '#find h3.results-list-item__heading' do
          expect(page).to have_link('Menil : the Menil collection',
                                    href: 'https://find.library.upenn.edu/catalog/9960586893503681',
                                    exact: true)
        end
      end
    end

    context 'with archives results' do
      it 'displays expected title' do
        within '#finding_aids h3.results-list-item__heading' do
          expect(page).to have_link('Kronish, Lieb, Weiner, and Hellman LLP Bankruptcy Judges Lawsuit files',
                                    href: 'https://findingaids.library.upenn.edu/records/UPENN_BIDDLE_PU-L.NBA.027',
                                    exact: true)
        end
      end
    end

    context 'with museum results' do
      it 'displays expected title' do
        within '#museum h3.results-list-item__heading' do
          expect(page).to have_link('Hebrew Bowl - B13186',
                                    href: 'https://www.penn.museum/collections/object/297737',
                                    exact: true)
        end
      end
    end

    context 'with art collection results' do
      it 'displays expected title' do
        within '#art_collection h3.results-list-item__heading' do
          expect(page).to have_link("Leonardo's Lady",
                                    href: 'https://pennartcollection.com/collection/art/194/leonardos-lady/',
                                    exact: true)
        end
      end
    end
  end
end
