# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  let(:bib) { '9913203433503681' }

  before do
    SampleIndexer.index 'print_monograph.json'
    allow(Inventory::Service).to receive(:full).and_return(Inventory::Response.new(entries: []))
    visit solr_document_path bib
  end

  after { SampleIndexer.clear! }

  it 'shows document' do
    expect(page).to have_selector 'div.document-main-section'
  end

  it 'shows some item metadata' do
    expect(page).to have_selector 'dd.blacklight-creator_show'
  end

  context 'when returning to search results' do
    before do
      allow(Inventory::Service).to receive(:brief).and_return(Inventory::Response.new(entries: []))
    end

    it 'returns to Index' do
      click_on I18n.t('search.button.label')
      expect(page).to have_selector 'article.document-position-1'
    end
  end

  context 'with show tools' do
    context 'when a user is signed in' do
      before do
        sign_in create(:user)
        visit solr_document_path bib
      end

      it 'displays a link to email the record' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link 'Email', href: "/catalog/#{bib}/email"
      end
    end

    context 'when a user is not signed in' do
      it 'displays a link to login' do
        click_on I18n.t('blacklight.tools.title')
        expect(page).to have_link I18n.t('blacklight.tools.login_for_email'), href: "#{login_path}?id=#{bib}"
      end
    end

    it 'displays Staff view link' do
      click_on I18n.t('blacklight.tools.title')
      expect(page).to have_link I18n.t('blacklight.tools.staff_view'), href: "/catalog/#{bib}/staff_view"
    end
  end
end
