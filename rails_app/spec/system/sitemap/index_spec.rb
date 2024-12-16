# frozen_string_literal: true

require 'system_helper'

xdescribe 'Sitemap Index Page' do
  include_context 'with print monograph record with 2 physical entries'

  before { visit blacklight_dynamic_sitemap.sitemap_index_path }

  it 'renders XML with root element' do
    expect(page.body).to have_xpath('//sitemapindex')
  end
end
