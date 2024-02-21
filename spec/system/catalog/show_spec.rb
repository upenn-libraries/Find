# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  before do
    SampleIndexer.index 'print_monograph.json'
    visit solr_document_path '9913203433503681'
  end

  after { SampleIndexer.clear! }

  it 'shows document' do
    expect(page).to have_selector 'div.document-main-section'
  end

  it 'shows some item metadata' do
    expect(page).to have_selector 'dd.blacklight-title_show'
    expect(page).to have_selector 'dd.blacklight-creator_show'
  end

  it 'returns to Index when search is executed' do
    click_on I18n.t('search.button.label')
    expect(page).to have_selector 'article.document-position-1'
  end
end
