# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  before do
    SampleIndexer.index 'print_monograph.json'
    allow(Inventory::Service).to receive(:all).and_return(Inventory::Response.new(entries: []))
    visit root_path
  end

  after { SampleIndexer.clear! }

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

  it 'opens a result page' do
    click_on I18n.t('search.button.label')
    within('article.document-position-1') { find('a').click }
    expect(page).to have_selector 'section.show-document'
  end

  context 'when logged out' do
    let(:user) { create(:user) }

    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(true)
    end

    it 'redirects to index page after login' do
      visit login_path
      click_on I18n.t('login.pennkey')
      expect(page).to have_current_path(root_path)
    end
  end
end
