# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  let(:bib) { '9913203433503681' }

  before do
    SampleIndexer.index 'print_monograph.json'
    allow(Inventory::Service).to receive(:all).and_return(Inventory::Response.new(entries: []))
    visit solr_document_path bib
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

  it 'displays Librarian view link' do
    expect(page).to have_link 'Librarian view', href: "/catalog/#{bib}/librarian_view"
  end
end
