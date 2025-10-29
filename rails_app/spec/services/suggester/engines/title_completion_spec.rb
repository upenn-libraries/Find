# frozen_string_literal: true

describe Suggester::Engines::TitleCompletion do
  let(:engine) { described_class.new(query: 'test', context: {}) }

  describe '.weight' do
    it 'returns expected base weight' do
      expect(described_class.weight).to eq 2
    end
  end

  describe '.suggest?' do
    context 'with a query' do
      it 'returns true' do
        expect(described_class.suggest?('test')).to be true
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
      expect(actions).to be_a(Suggester::Suggestion)
    end

    it 'contains no entries' do
      expect(actions).to have_attributes(entries: [])
    end
  end

  describe '#completions' do
    let(:completions) { engine.completions }

    it 'returns a Suggestions instance' do
      expect(completions).to be_a(Suggester::Suggestion)
    end

    it 'contains expected entries' do
      expect(completions).to have_attributes(entries: ['Title containing test', 'Another title containing test'])
    end
  end
end
