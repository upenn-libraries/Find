# frozen_string_literal: true

describe Suggester::Suggestions::Collection do
  let(:suggestion_collection) { described_class.new(suggestions: suggestions) }
  let(:suggestions) do
    [Suggester::Suggestions::Suggestion.new(entries: ['foo'], weight: 0),
     Suggester::Suggestions::Suggestion.new(entries: %w[bar baz], weight: 1)]
  end

  describe '#suggestions' do
    it 'returns sorted suggestions' do
      expect(suggestion_collection.suggestions).to eq suggestions.reverse
    end

    context 'with blank suggestions' do
      let(:suggestions) { [Suggester::Suggestions::Suggestion.new(entries: [])] }

      it 'removes them from the array' do
        expect(suggestion_collection.suggestions).to eq []
      end
    end
  end

  describe '#provide' do
    context 'with no limit provided' do
      it 'returns all the sorted suggestions' do
        expect(suggestion_collection.provide).to eq(%w[bar baz foo])
      end
    end

    context 'with limit provided' do
      it 'limits the sorted suggestions' do
        expect(suggestion_collection.provide(limit: 2)).to eq(%w[bar baz])
      end
    end
  end

  describe '#present?' do
    context 'with present suggestions' do
      it 'returns true' do
        expect(suggestion_collection.present?).to be true
      end
    end

    context 'without present suggestions' do
      let(:suggestions) { [Suggester::Suggestions::Suggestion.new] }

      it 'returns false' do
        expect(suggestion_collection.present?).to be false
      end
    end
  end
end
