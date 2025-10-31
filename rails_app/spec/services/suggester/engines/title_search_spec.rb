# frozen_string_literal: true

describe Suggester::Engines::TitleSearch do
  include_context 'with cleared engine registry'

  let(:engine) { described_class.new(query: 'query', context: {}) }

  describe '.weight' do
    it 'returns expected base weight' do
      expect(described_class.weight).to eq described_class::BASE_WEIGHT
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

    it 'contains expected entries' do
      expect(actions).to have_attributes(
        entries: [{ label: "Search 'query' in titles.",
                    url: 'https://find.library.upenn.edu?q=query&search_field=title_search' }]
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
