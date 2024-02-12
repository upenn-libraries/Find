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
      expect(page).to have_text(I18n.t('facets.access'))
    end
  end

  it 'searches and returns results' do
    fill_in 'q', with: 'cat'
    click_on 'Find it'
    within('article.document-position-1') { expect(page).to have_text('The hypothalamus of the cat') }
  end

  it 'opens a result page' do
    fill_in 'q', with: 'cat'
    click_on 'Find it'
    click_on 'The hypothalamus of the cat'
    within('section.show-document') { expect(page).to have_text('The hypothalamus of the cat') }
  end
end
