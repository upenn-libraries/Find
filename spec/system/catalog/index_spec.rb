# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  before do
    SampleIndexer.index 'print_monograph.json'
    visit root_path
  end

  after { SampleIndexer.clear! }

  it 'displays facets' do
    within('div.blacklight-access_facet') do
      expect(page).to have_text I18n.t('facets.access')
      click_on I18n.t('facets.access')
      expect(page).to have_text 'At the library'
    end
  end

  it 'searches and returns results' do
    click_on I18n.t('search.button.label')
    expect(page).to have_selector 'article.document-position-1'
  end

  it 'opens a result page' do
    click_on I18n.t('search.button.label')
    within('article.document-position-1') { find('a').click }
    expect(page).to have_selector 'section.show-document'
  end
end
