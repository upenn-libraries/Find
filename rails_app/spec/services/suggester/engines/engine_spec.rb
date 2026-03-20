# frozen_string_literal: true

describe Suggester::Engines::Engine do
  let(:engine) { described_class.new(query: 'query', context: {}) }

  describe '.actions_weight' do
    it 'declares the expected actions weight' do
      expect(described_class.actions_weight).to eq described_class::BASE_ACTIONS_WEIGHT
    end
  end

  describe '.completions_weight' do
    it 'declares the expected completions weight' do
      expect(described_class.completions_weight).to eq described_class::BASE_COMPLETIONS_WEIGHT
    end
  end

  describe '.suggest?' do
    it 'returns true when a query is present' do
      expect(described_class.suggest?('query')).to be true
    end

    it 'returns false when no query is present' do
      expect(described_class.suggest?('')).to be false
    end
  end

  describe '#actions' do
    let(:actions) { engine.actions }

    it 'returns a Suggestion instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains no entries' do
      expect(actions).to have_attributes(entries: [])
    end
  end

  describe '#completions' do
    let(:completions) { engine.completions }

    it 'returns a Suggestion instance' do
      expect(completions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains no entries' do
      expect(completions).to have_attributes(entries: [])
    end
  end

  describe '#success?' do
    it 'returns false' do
      expect(engine.success?).to be false
    end
  end
end
