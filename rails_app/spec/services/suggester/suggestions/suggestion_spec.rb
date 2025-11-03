# frozen_string_literal: true

describe Suggester::Suggestions::Suggestion do
  let(:suggestion) { described_class.new(entries: entries, engine_weight: 5, weight: 10) }
  let(:entries) { ['some completion'] }

  describe '#provide' do
    it 'returns entries' do
      expect(suggestion.provide).to eq(entries)
    end
  end

  describe '#score' do
    it 'returns the sum of the engine_weight and weight' do
      expect(suggestion.score).to eq 15
    end
  end

  describe '#<=>' do
    context 'when other score is higher' do
      let(:other_suggestion) { described_class.new(engine_weight: 5, weight: 11) }

      it 'returns -1' do
        expect(suggestion.score <=> other_suggestion.score).to eq(-1)
      end
    end

    context 'when other score is lower' do
      let(:other_suggestion) { described_class.new(engine_weight: 5, weight: 9) }

      it 'returns 1' do
        expect(suggestion.score <=> other_suggestion.score).to eq(1)
      end
    end

    context 'when other score is equal' do
      let(:other_suggestion) { suggestion }

      it 'returns 0' do
        expect(suggestion.score <=> other_suggestion.score).to eq(0)
      end
    end
  end
end
