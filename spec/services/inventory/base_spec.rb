# frozen_string_literal: true

describe Inventory::Base do
  describe '#location' do
    let(:raw_availability_data) { {} }
    let(:inventory) do
      described_class.new('id', raw_availability_data)
    end

    context 'without a location override' do
      let(:raw_availability_data) { { 'location_code' => 'vanp' } }

      it 'returns expected value' do
        location_code = inventory.raw_availability_data['location_code'].to_sym
        expect(inventory.location).to eq PennMARC::Mappers.location[location_code][:display]
      end
    end

    context 'with a location override' do
      let(:raw_availability_data) { { 'location_code' => 'vanp', 'call_number' => 'ML3534 .D85 1984' } }

      it 'returns expected value' do
        expect(inventory.location).to eq PennMARC::Mappers.location_overrides[:albrecht][:specific_location]
      end
    end
  end

  describe '#to_h' do
    let(:inventory) do
      described_class.new('id', {})
    end

    it 'returns formatted hash' do
      expect(inventory.to_h).to eq({ count: nil, description: nil, format: nil,
                                     href: nil, id: nil, location: nil, policy: nil,
                                     status: nil, type: nil })
    end
  end
end
