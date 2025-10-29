# frozen_string_literal: true

describe Suggester::SuggestionCollection do
  let(:suggestion_collection) { described_class.new(suggestions: suggestions) }
  let(:suggestions) { [Suggester::Suggestion.new(entries: ['foo'], weight: 0), Suggester::Suggestion.new(entries: %w[bar baz], weight: 1)] }

  describe '#suggestions' do
    it 'returns sorted suggestions' do
      expect(suggestion_collection.suggestions).to eq suggestions.reverse
    end

    context 'with blank suggestions' do
      let(:suggestions) { [Suggester::Suggestion.new(entries: [])] }

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
      let(:suggestions) { [Suggester::Suggestion.new] }

      it 'returns false' do
        expect(suggestion_collection.present?).to be false
      end
    end
  end
end
