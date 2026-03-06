# frozen_string_literal: true

describe 'Sitemap Controller Requests' do
  include_context 'with print monograph record with 2 physical entries'

  context 'GET sitemap index' do
    before { get blacklight_dynamic_sitemap.sitemap_index_path }

    it 'renders XML with sitemapindex root element' do
      expect(response.body).to include '<sitemapindex'
    end
  end

  context 'GET sitemap show' do
    before { get blacklight_dynamic_sitemap.sitemap_path('0') }

    it 'renders XML with urlset root element' do
      expect(response.body).to include '<urlset'
    end
  end
end
