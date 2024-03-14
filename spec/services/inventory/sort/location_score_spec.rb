# frozen_string_literal: true

describe Inventory::Sort::LocationScore do
  let(:data) do
    {
      'total_items' => '1',
      'non_available_items' => '0',
      'location_code' => 'vanp',
      'coverage_statement' => 'from 1985'
    }
  end

  let(:score) { described_class.score(data) }

  describe '.location_score' do
    context 'with a convenient location' do
      it 'returns the expected value' do
        expect(score).to eq described_class::BASE_SCORE
      end
    end

    context 'with an offsite location' do
      let(:data) { { 'location_code' => 'stor' } }

      it 'returns the expected value' do
        expect(score).to eq described_class::DECREMENT
      end
    end

    context 'with an unavailable location' do
      let(:data) { { 'location_code' => 'vpunavail' } }

      it 'returns the expected value' do
        expect(score).to eq described_class::DECREMENT * described_class::MULTIPLIER
      end
    end
  end
end
