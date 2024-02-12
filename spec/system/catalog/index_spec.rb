# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  before do
    SampleIndexer.index 'print_monograph.json'
    visit root_path
  end

  after { SampleIndexer.clear! }

  it 'displays the access facet' do
    within('div.blacklight-access_facet') do
      expect(page).to have_text(I18n.t('facets.access'))
    end
  end
end
