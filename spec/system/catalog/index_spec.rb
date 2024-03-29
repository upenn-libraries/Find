# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  include_context 'with print monograph record'

  before { visit root_path }

  it 'displays facets' do
    within('div.blacklight-access_facet') do
      expect(page).to have_text I18n.t('facets.access')
      click_on I18n.t('facets.access')
      expect(page).to have_text PennMARC::Access::AT_THE_LIBRARY
    end
  end

  it 'searches and returns results' do
    click_on I18n.t('search.button.label')
    expect(page).to have_selector 'article.document-position-1'
  end

  it 'opens a result page when clicking on a record' do
    click_on I18n.t('search.button.label')
    within('article.document-position-1') { find('a').click }
    expect(page).to have_selector 'section.show-document'
  end
end
