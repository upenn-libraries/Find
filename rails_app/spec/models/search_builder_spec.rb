# frozen_string_literal: true

require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new(scope).with(blacklight_params) }

  let(:blacklight_params) { {} }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:scope) { instance_double CatalogController, blacklight_config: blacklight_config, action_name: 'index' }

  describe '#facets_for_advanced_search_form' do
    before { allow(scope).to receive(:action_name).and_return('advanced_search') }

    it 'appends advanced search form_solr_parameters to blacklight_params' do
      search_builder.facets_for_advanced_search_form(blacklight_params)
      expect(blacklight_params).to eq scope.blacklight_config.advanced_search[:form_solr_parameters]
    end
  end

  describe '#handle_standalone_boolean_operators' do
    before { search_builder.handle_standalone_boolean_operators(blacklight_params) }

    context 'with standalone operators' do
      let(:blacklight_params) { { q: 'cookies + milk' } }

      it 'escapes a single operator' do
        expect(blacklight_params[:q]).to include '\+ milk'
      end
    end

    context 'with standalone operators and whitespace' do
      let(:blacklight_params) { { q: 'cookies   -  milk' } }

      it 'escapes a single operator regardless of the amount of surrounding whitespace' do
        expect(blacklight_params[:q]).to include '\-  milk'
      end
    end

    context 'with multiple standalone operators' do
      let(:blacklight_params) { { q: 'cookies + milk ! hooray' } }

      it 'escapes multiple operators' do
        expect(blacklight_params[:q]).to include '\+ milk \!'
      end
    end

    context 'with proper operator syntax' do
      let(:search_term) { 'hypothalamus +cat -dog' }
      let(:blacklight_params) { { q: search_term } }

      it 'does not escape the operator characters' do
        expect(blacklight_params[:q]).to eq search_term
      end
    end
  end

  describe '#massage_sort' do
    before { search_builder.massage_sort(blacklight_params) }

    context 'with no search parameters' do
      let(:blacklight_params) { {} }

      it 'sets the induced sort' do
        expect(blacklight_params[:sort]).to eq SearchBuilder::INDUCED_SORT.join(',')
      end
    end

    context 'with a sort parameter defined' do
      let(:title_sort) { SearchBuilder::TITLE_SORT_ASC.join(',') }
      let(:blacklight_params) { { sort: title_sort } }

      it 'does not alter the sort value' do
        expect(blacklight_params[:sort]).to eq title_sort
      end
    end

    context 'with a basic search term provided' do
      let(:blacklight_params) { { q: 'term' } }

      it 'sets the sort value to relevance sort' do
        expect(blacklight_params[:sort]).to eq SearchBuilder::RELEVANCE_SORT.join(',')
      end
    end

    context 'with no search term and an "Online" Access facet applied' do
      let(:blacklight_params) { { f: { access_facet: [PennMARC::Access::ONLINE] } } }

      it 'sets the has-electronic-holdings sort dimension first' do
        expect(blacklight_params[:sort]).to eq(
          ['min(def(electronic_portfolio_count_i,0),1) desc',
           'encoding_level_sort asc',
           'updated_date_sort desc'].join(',')
        )
      end
    end

    context 'with no search term and an "At the Library" Access facet applied' do
      let(:blacklight_params) { { f: { access_facet: [PennMARC::Access::AT_THE_LIBRARY] } } }

      it 'sets the has-physical-holdings sort dimension first' do
        expect(blacklight_params[:sort]).to eq(
          ['min(def(physical_holding_count_i,0),1) desc',
           'encoding_level_sort asc',
           'updated_date_sort desc'].join(',')
        )
      end
    end

    context 'with an advanced search request' do
      let(:blacklight_params) { { json: { query: { bool: { must: [] } } } } }

      it 'does not modify sort param' do
        expect(blacklight_params[:sort]).to be_nil
      end
    end
  end
end
