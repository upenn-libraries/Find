# frozen_string_literal: true

require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new [], scope }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new([], blacklight_config) }

  describe '#handle_standalone_boolean_operators' do
    context 'with standalone operators' do
      it 'escapes a single operator' do
        expect(search_builder.handle_standalone_boolean_operators(
                 q: 'cookies + milk'
               )).to include '\+ milk'
      end

      it 'escapes a single operator regarless of the amount of surrounding whitespace' do
        expect(search_builder.handle_standalone_boolean_operators(
                 q: 'cookies   -  milk'
               )).to include '\-  milk'
      end

      it 'escapes multiple operators' do
        expect(search_builder.handle_standalone_boolean_operators(
                 q: 'cookies + milk ! hooray'
               )).to include '\+ milk \!'
      end
    end

    context 'with proper operator syntax' do
      let(:params) { ActionController::Parameters.new q: query }
      let(:query) { 'hypothalamus +cat -dog' }

      it 'does not escape the operator characters' do
        expect(search_builder.handle_standalone_boolean_operators(params)).to eq query
      end
    end
  end
end
