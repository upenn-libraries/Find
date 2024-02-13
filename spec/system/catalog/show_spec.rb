# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  before do
    SampleIndexer.index 'print_monograph.json'
    visit solr_document_path('9913203433503681')
  end

  after { SampleIndexer.clear! }

  it 'shows record title' do
    within('div.document-main-section') do
      expect(page).to have_text 'The hypothalamus of the cat'
    end
  end

  it 'shows some item metadata' do
    within('dd.blacklight-creator_show') do
      expect(page).to have_text 'Bleier, Ruth, 1923-'
    end
  end

  it 'searches and returns results' do
    fill_in 'q', with: 'cat'
    click_on I18n.t('search.button.label')
    within('article.document-position-1') { expect(page).to have_text('The hypothalamus of the cat') }
  end
end
