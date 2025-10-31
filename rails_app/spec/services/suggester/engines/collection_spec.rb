# frozen_string_literal: true

describe Suggester::Engines::Collection do
  include Suggester::SpecHelpers
  let(:engine_collection) { described_class.new(query: 'query', context: context, engine_classes: engines) }
  let(:context) { Suggester::Service::DEFAULT_CONTEXT }
  let(:engines) { [mock_engine_with_actions, mock_engine_with_completions] }

  describe '#suggestions' do
    it 'returns actions and completions' do
      expect(engine_collection.suggestions).to eq({ suggestions: {
                                                    actions: [
                                                      { label: 'Search titles for "query"',
                                                        url: 'https://find.library.upenn.edu/?field=title&q=query' }
                                                    ],
                                                    completions: ['query syntax', 'query language', 'query errors',
                                                                  'adversarial queries']

                                                  } })
    end

    context 'with unsuccessful engines' do
      let(:engines) do
        [mock_engine_class(actions: Suggester::Suggestions::Suggestion.new(entries: [{ label: 'label', url: '/' }]),
                           success: false),
         mock_engine_class(completions: Suggester::Suggestions::Suggestion.new(entries: ['some query completion']),
                           success: false)]
      end

      it 'filters out suggestions' do
        expect(engine_collection.suggestions).to eq({ suggestions: { actions: [], completions: [] } })
      end
    end
  end

  describe '#status' do
    context 'with successful engine calls' do
      it 'returns success' do
        expect(engine_collection.status).to eq :success
      end
    end

    context 'without any successful engine calls' do
      let(:engines) { [mock_engine_class(success: false)] }

      it 'returns failure' do
        expect(engine_collection.status).to eq :failure
      end
    end
  end
end
