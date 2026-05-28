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

      it 'returns regular display name when non-LC type call number happens to matches the pattern' do
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

    context 'when the item is in a RES_SHARE library' do
      let(:location) { create :location, :res_share }

      it 'returns our custom label' do
        expect(location.location_name).to eq I18n.t('inventory.res_share_location_label')
      end
    end
  end
end
