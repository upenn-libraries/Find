# frozen_string_literal: true

describe Inventory::Location do
  describe '#location_name' do
    context 'without a location override' do
      let(:location) { create(:location) }

      it 'returns expected name' do
        location_code = location.code.to_sym
        expect(location.location_name).to eq Mappings.locations[location_code][:display]
      end
    end

    context 'with a location override' do
      let(:location) { create(:location, location_code: 'vanp') }

      it 'returns expected name' do
        expect(
          location.location_name(call_number: 'ML3534 .D85 1984',
                                 call_number_type: PennMARC::Classification::LOC_CALL_NUMBER_TYPE)
        ).to eq Mappings.location_overrides[:albrecht][:specific_location]
      end

      it 'returns display name when non-LC call number matches the pattern' do
        expect(
          location.location_name(call_number: 'Microfilm 1234',
                                 call_number_type: '8')
        ).to eq Mappings.locations[location.code.to_sym][:display]
      end
    end

    context 'when location code is not found in mappings' do
      let(:location) { create(:location, location_code: 'invalid', location_name: 'alma_location') }

      it 'defaults to alma location value' do
        expect(location.location_name).to eq 'alma_location'
      end
    end
  end

  describe '#aeon?' do
    it 'returns true if location at aeon location' do
      location = create(:location, :aeon)
      expect(location.aeon?).to be true
    end

    it 'returns false if location is not aeon location' do
      location = create(:location)
      expect(location.aeon?).to be false
    end
  end

  describe '#archives?' do
    it 'returns true if location is at archives' do
      location = create :location, :archives
      expect(location.archives?).to be true
    end

    it 'returns false if location is not at archives' do
      location = create :location
      expect(location.archives?).to be false
    end
  end

  describe '#hsp?' do
    it 'returns true if item is at HSP' do
      location = create :location, :hsp
      expect(location.hsp?).to be true
    end

    it 'returns false if item is not at HSP' do
      location = create :location
      expect(location.hsp?).to be false
    end
  end
end
