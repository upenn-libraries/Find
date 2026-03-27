# frozen_string_literal: true

require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new(scope).with(blacklight_params) }

  # user params coming from the search state
  let(:blacklight_params) { {} }
  # solr friendly processed params passed down the search builder processor chain
  let(:solr_params) { {} }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:scope) { instance_double CatalogController, blacklight_config: blacklight_config, action_name: 'index' }

  describe '#handle_standalone_boolean_operators' do
    before { search_builder.handle_standalone_boolean_operators(solr_params) }

    context 'with standalone operators' do
      let(:solr_params) { { q: 'cookies + milk' } }

      it 'escapes a single operator' do
        expect(solr_params[:q]).to include '\+ milk'
      end
    end

    context 'with standalone operators and whitespace' do
      let(:solr_params) { { q: 'cookies   -  milk' } }

      it 'escapes a single operator regardless of the amount of surrounding whitespace' do
        expect(solr_params[:q]).to include '\-  milk'
      end
    end

    context 'with multiple standalone operators' do
      let(:solr_params) { { q: 'cookies + milk ! hooray' } }

      it 'escapes multiple operators' do
        expect(solr_params[:q]).to include '\+ milk \!'
      end
    end

    context 'with proper operator syntax' do
      let(:search_term) { 'hypothalamus +cat -dog' }
      let(:solr_params) { { q: search_term } }

      it 'does not escape the operator characters' do
        expect(solr_params[:q]).to eq search_term
      end
    end
  end

  describe '#massage_sort' do
    let(:sort_builder) { instance_double SortBuilder }

    before do
      allow(SortBuilder).to receive(:new).and_return(sort_builder)
      allow(sort_builder).to receive_messages({ enriched_relevance_sort: 'mock_relevance_sort',
                                                browse_sort: 'mock_browse_sort' })
      search_builder.massage_sort(solr_params)
    end

    context 'with no search parameters' do
      it 'initializes SortBuilder with blacklight_params' do
        expect(SortBuilder).to have_received(:new).with(blacklight_params)
      end

      it 'sets the induced sort' do
        expect(solr_params[:sort]).to eq 'mock_browse_sort'
      end
    end

    context 'with a sort parameter defined' do
      let(:solr_params) { { sort: 'title_sort asc' } }

      it 'does not alter the sort value' do
        expect(solr_params[:sort]).to eq 'title_sort asc'
      end
    end

    context 'with a basic search term provided' do
      let(:solr_params) { { q: 'term' } }

      it 'sets the sort value to relevance sort' do
        expect(solr_params[:sort]).to eq 'mock_relevance_sort'
      end
    end

    context 'with no search term and an "Online" Access facet applied' do
      let(:blacklight_params) { { f: { access_facet: [PennMARC::Access::ONLINE] } } }

      it 'sets the has-electronic-holdings sort dimension first' do
        expect(solr_params[:sort]).to eq 'mock_browse_sort'
      end
    end

    context 'with no search term and an "At the Library" Access facet applied' do
      let(:blacklight_params) { { f: { access_facet: [PennMARC::Access::AT_THE_LIBRARY] } } }

      it 'sets the has-physical-holdings sort dimension first' do
        expect(solr_params[:sort]).to eq('mock_browse_sort')
      end
    end

    context 'with an advanced search request' do
      let(:solr_params) { { json: { query: { bool: { must: [] } } } } }

      it 'does not modify sort param' do
        expect(solr_params[:sort]).to be_nil
      end
    end

    context 'with a database search' do
      let(:blacklight_params) { { f: { format_facet: [PennMARC::Database::DATABASES_FACET_VALUE] } } }

      it 'sets the database sort' do
        expect(solr_params[:sort]).to eq SortBuilder.title_sort_asc
      end
    end
  end
end
