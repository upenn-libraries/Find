# frozen_string_literal: true

describe Suggester::Engines::OnlineAccess do
  include_context 'with cleared engine registry'

  let(:engine) { described_class.new(query: 'query', context: {}) }

  describe '.actions_weight' do
    it 'returns expected base actions weight' do
      expect(described_class.actions_weight).to eq described_class::BASE_ACTIONS_WEIGHT
    end
  end

  describe '.suggest?' do
    context 'with a query' do
      it 'returns true' do
        expect(described_class.suggest?('query')).to be true
      end
    end

    context 'without a query' do
      it 'returns false' do
        expect(described_class.suggest?('')).to be false
      end
    end
  end

  describe '#actions' do
    let(:actions) { engine.actions }

    it 'returns a Suggestions instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'returns contains expected entries' do
      expect(actions.entries).to contain_exactly(
        an_object_having_attributes(
          label: '<b>query</b> in Online Resources',
          url: 'https://find.library.upenn.edu?f%5Baccess_facet%5D%5B%5D=Online&q=query'
        )
      )
    end
  end

  describe '#completions' do
    let(:completions) { engine.completions }

    it 'returns a Suggestions instance' do
      expect(completions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains no entries' do
      expect(completions).to have_attributes(entries: [])
    end
  end
end
