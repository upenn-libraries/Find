# frozen_string_literal: true

describe Suggester::Engines::ArticleSearch do
  include_context 'with cleared engine registry'

  let(:engine) { described_class.new(query: 'query', context: {}) }

  describe '.weight' do
    it 'returns expected base weight' do
      expect(described_class.weight).to eq described_class::BASE_WEIGHT
    end
  end

  describe '.suggest?' do
    context 'with a query containing more than 10 words' do
      it 'returns true' do
        expect(described_class.suggest?('oh what a coincidence this query has more than ten words')).to be true
      end
    end

    context 'with a query containing less than 10 words' do
      it 'returns false' do
        expect(described_class.suggest?('query')).to be false
      end
    end
  end

  describe '#actions' do
    let(:actions) { engine.actions }

    it 'returns a Suggestions instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'returns expected entries' do
      url = 'https://proxy.library.upenn.edu/login?url=https://upenn.summon.serialssolutions.com/search?s.q=query'
      expect(actions).to have_attributes(
        entries: [{ label: '<b>query</b> in Articles+', url: url }]
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
