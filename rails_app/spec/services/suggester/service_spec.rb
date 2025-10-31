# frozen_string_literal: true

describe Suggester::SuggestionsService do
describe Suggester::Service do
  include Suggester::SpecHelpers
  let(:service) { described_class.new(query: 'query', context: { foo: 'bar' }, engine_classes: engines) }
  let(:engines) { [mock_engine_with_actions, mock_engine_with_completions] }

  describe '#context' do
    it 'merges in default context' do
      expect(service.context).to eq({ foo: 'bar', **described_class::DEFAULT_CONTEXT })
    end
  end

  describe '#response' do
    context 'with successful engines' do
      it 'returns expected response' do
        expect(service.response).to eq({ status: :success,
                                         data: {
                                           params: { q: 'query',
                                                     context: { foo: 'bar', 'actions_limit': 2,
                                                                'completions_limit': 4 } },
                                           suggestions: {
                                             actions: [{ label: 'Search titles for "query"',
                                                         url: 'https://find.library.upenn.edu/?field=title&q=query' }],
                                             completions: ['query syntax', 'query language', 'query errors',
                                                           'adversarial queries']
                                           }
                                         } })
      end
    end

    context 'with unsuccessful engines' do
      let(:engines) { [mock_engine_class(success: false)] }

      it 'returns expected response' do
        expect(service.response).to eq({ status: :failure,
                                         data: {
                                           params: { q: 'query',
                                                     context: { foo: 'bar', 'actions_limit': 2,
                                                                'completions_limit': 4 } },
                                           suggestions: { actions: [], completions: [] }
                                         } })
      end
    end
  end
end
