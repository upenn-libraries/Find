# frozen_string_literal: true

describe Inventory::List::Sort::LocationScore do
  let(:data) { build(:physical_availability_data) }
  let(:score) { described_class.score(data) }

  describe '.location_score' do
    context 'with a convenient location' do
      it 'returns the expected value' do
        expect(score).to eq described_class::BASE_SCORE
      end
    end

    context 'with an offsite location' do
      let(:data) { build(:physical_availability_data, location_code: 'stor') }

      it 'returns the expected value' do
        expect(score).to eq described_class::OFFSITE_SCORE
      end
    end

    context 'with an unavailable location' do
      let(:data) { build(:physical_availability_data, location_code: 'vpunavail') }

      it 'returns the expected value' do
        expect(score).to eq described_class::UNAVAILABLE_SCORE
      end
    end
  end
end
