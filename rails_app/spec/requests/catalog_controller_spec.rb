# frozen_string_literal: true

describe 'Catalog Controller Requests' do
  before do
    SampleIndexer.index 'print_monograph.json'
    get search_catalog_path(params), headers: headers
  end

  context 'when using the JSON API' do
    let(:headers) { { 'HTTP_ACCEPT' => 'application/json' } }
    let(:parsed_response) { JSON.parse response.body }
    let(:params) { {} }

    it 'returns the expected attributes' do
      expected_keys = %w[title format_facet creator_ss publication_ss marcxml_marcxml id oclc_id_ss library_facet]
      expect(parsed_response['data'].first['attributes'].keys).to include(*expected_keys)
    end
  end
end
