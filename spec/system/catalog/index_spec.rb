# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Index Page' do
  before { visit root_path }

  it 'displays the access facet' do
    within('div.blacklight-access_facet') do
      expect(page).to have_text(t('facets.access'))
    end
  end
end
