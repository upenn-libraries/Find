# frozen_string_literal: true

describe Inventory::Entry do
  describe '#location' do
    let(:data) { {} }
    let(:inventory) do
      described_class.new('id', data)
    end

    context 'without a location override' do
      let(:data) { { location_code: 'vanp' } }

      it 'returns expected value' do
        location_code = inventory.data[:location_code].to_sym
        expect(inventory.location).to eq PennMARC::Mappers.location[location_code][:display]
      end
    end

    context 'with a location override' do
      let(:data) { { location_code: 'vanp', call_number: 'ML3534 .D85 1984' } }

      it 'returns expected value' do
        expect(inventory.location).to eq PennMARC::Mappers.location_overrides[:albrecht][:specific_location]
      end
    end
  end
end
