# frozen_string_literal: true

require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new search_service }

  let(:controller) { instance_double CatalogController }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:search_state) { Blacklight::SearchState.new(params, blacklight_config, controller) }
  let(:search_service) { Blacklight::SearchService.new(config: blacklight_config, search_state: search_state) }

  # we're testing the return value of the method - which may not be the actual value of the query params in
  # the SearchBuilder's params...
  describe '#handle_standalone_boolean_operators' do
    before { allow(controller).to receive(:action_name).and_return('index') }

    context 'with standalone operators' do
      let(:params) { { q: 'cookies + milk' } }

      it 'escapes a single operator' do
        expect(search_builder.handle_standalone_boolean_operators(params)).to include '\+ milk'
      end
    end

    context 'with standalone operators and whitespace' do
      let(:params) { { q: 'cookies   -  milk' } }

      it 'escapes a single operator regardless of the amount of surrounding whitespace' do
        expect(search_builder.handle_standalone_boolean_operators(params)).to include '\-  milk'
      end
    end

    context 'with multiple standalone operators' do
      let(:params) { { q: 'cookies + milk ! hooray' } }

      it 'escapes multiple operators' do
        expect(search_builder.handle_standalone_boolean_operators(params)).to include '\+ milk \!'
      end
    end

    context 'with proper operator syntax' do
      let(:params) { { q: 'hypothalamus +cat -dog' } }

      it 'does not escape the operator characters' do
        expect(search_builder.handle_standalone_boolean_operators(params)).to eq params[:q]
      end
    end
  end

  # again here it'd be better for us to check the params as stored on the search_builder object, not the method return
  # value. the cases here where the return value is nil are particularly smelly.
  describe '#massage_sort' do
    context 'with no search parameters' do
      let(:params) { {} }

      it 'sets the induced sort' do
        expect(search_builder.massage_sort(params)).to eq SearchBuilder::INDUCED_SORT.join(',')
      end
    end

    context 'with a sort parameter defined' do
      let(:params) { { sort: SearchBuilder::TITLE_SORT_ASC.join(',') } }

      it 'does not alter the sort value' do
        expect(search_builder.massage_sort(params)).to be_nil
      end
    end

    context 'with a basic search term provided' do
      let(:params) { { q: 'term' } }

      it 'sets the expected sort value' do
        expect(search_builder.massage_sort(params)).to eq SearchBuilder::RELEVANCE_SORT.join(',')
      end
    end

    context 'with no search term and an Access facet applied' do
      let(:params) { { f: { access_facet: [PennMARC::Access::ONLINE] } } }

      it 'sets the expected sort value' do
        expect(search_builder.massage_sort(params)).to eq(
          ['encoding_level_sort asc',
           'updated_date_sort desc',
           'min(def(electronic_portfolio_count_i,0),1) desc'].join(',')
        )
      end
    end

    context 'with an advanced search request' do
      let(:params) { {} }

      before { allow(controller).to receive(:action_name).and_return('advanced_search') }

      it 'does not modify sort param' do
        expect(search_builder.massage_sort(params)).to be_nil
      end
    end
  end
end
