# frozen_string_literal: true

describe Catalog::QueryLinkComponent, type: :components do
  let(:solr_document) { SolrDocument.new('field' => ['show value']) }
  let(:field_config) { Blacklight::Configuration::Field.new(key: 'field', field: 'field', search_target: 'title_search') }
  let(:component) do
    described_class.new(field: Blacklight::FieldPresenter.new(vc_test_controller.view_context, solr_document,
                                                              field_config))
  end
  let(:query_params) { {} }

  describe '#link_to_query' do
    context 'when query is found in query map' do
      let(:field_config) do
        Blacklight::Configuration::Field.new(key: 'field', field: 'field', search_target: 'title_search',
                                             query_map: :test_title_search_map)
      end

      let(:query_map) { { solr_document['field'].first => 'query value' } }

      let(:query_params) do
        {
          clause: {
            "2": {
              field: field_config.search_target,
              query: "\"#{query_map[solr_document['field'].first]}\""
            }
          }
        }
      end

      before do
        allow(solr_document).to receive(:marc).with(field_config.query_map).and_return(query_map)
        render_inline(component)
      end

      it 'links to the found query' do
        expect(page).to have_link(solr_document['field'].first, href: search_catalog_path(query_params))
      end
    end

    context 'when no query is found in query map' do
      let(:field_config) do
        Blacklight::Configuration::Field.new(key: 'field', field: 'field', search_target: 'title_search',
                                             query_map: :test_title_search_map)
      end

      let(:query_map) { { solr_document['field'].first => nil } }

      before do
        allow(solr_document).to receive(:marc).with(field_config.query_map).and_return(query_map)
        render_inline(component)
      end

      it 'renders show value as plain text' do
        expect(page).to have_text(solr_document['field'].first)
        expect(page).not_to have_link(solr_document['field'].first)
      end
    end

    context 'when no query map provided' do
      let(:query_params) do
        {
          clause: {
            "2": {
              field: field_config.search_target,
              query: "\"#{solr_document['field'].first}\""
            }
          }
        }
      end

      before { render_inline(component) }

      it 'links to show value' do
        expect(page).to have_link(solr_document['field'].first, href: search_catalog_path(query_params))
      end
    end
  end
end
