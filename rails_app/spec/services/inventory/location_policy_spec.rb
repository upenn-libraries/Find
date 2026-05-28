# frozen_string_literal: true

describe Inventory::LocationPolicy do
  subject(:policy) { described_class.new(location) }

  describe '#requires_authentication?' do
    it 'returns false for an Aeon location' do
      policy = described_class.new(create(:location, :aeon))
      expect(policy.requires_authentication?).to be false
    end

    it 'returns false for an Archives location' do
      policy = described_class.new(create(:location, :archives))
      expect(policy.requires_authentication?).to be false
    end

    it 'returns false for an HSP location' do
      policy = described_class.new(create(:location, :hsp))
      expect(policy.requires_authentication?).to be false
    end

    it 'returns true for a standard location' do
      policy = described_class.new(create(:location))
      expect(policy.requires_authentication?).to be true
    end
  end

  describe '#available_status_key' do
    it 'returns :offsite_appointment for an Aeon+LIBRA location' do
      policy = described_class.new(create(:location, :aeon_offsite))
      expect(policy.available_status_key).to eq :offsite_appointment
    end

    it 'returns :appointment for an Aeon location' do
      policy = described_class.new(create(:location, :aeon))
      expect(policy.available_status_key).to eq :appointment
    end

    it 'returns :offsite for a LIBRA location' do
      policy = described_class.new(create(:location, :libra))
      expect(policy.available_status_key).to eq :offsite
    end

    it 'returns :unrequestable for an Archives location' do
      policy = described_class.new(create(:location, :archives))
      expect(policy.available_status_key).to eq :unrequestable
    end

    it 'returns :unrequestable for an HSP location' do
      policy = described_class.new(create(:location, :hsp))
      expect(policy.available_status_key).to eq :unrequestable
    end

    it 'returns :circulates for a standard location' do
      policy = described_class.new(create(:location))
      expect(policy.available_status_key).to eq :circulates
    end
  end

  describe '#check_holdings_status_key' do
    it 'returns :appointment for an Aeon location' do
      policy = described_class.new(create(:location, :aeon))
      expect(policy.check_holdings_status_key).to eq :appointment
    end

    it 'returns :mixed_availability for a non-Aeon location' do
      policy = described_class.new(create(:location))
      expect(policy.check_holdings_status_key).to eq :mixed_availability
    end
  end

  describe '#unavailable_status_key' do
    it 'returns :appointment for an Aeon location' do
      policy = described_class.new(create(:location, :aeon))
      expect(policy.unavailable_status_key).to eq :appointment
    end

    it 'returns nil for a non-Aeon location' do
      policy = described_class.new(create(:location))
      expect(policy.unavailable_status_key).to be_nil
    end
  end

  describe 'dependency injection' do
    it 'respects injected aeon_locations' do
      loc = Inventory::Location.new(
        library_code: 'lib', library_name: 'Lib',
        location_code: 'aeonloc', location_name: 'Aeon Loc'
      )
      policy = described_class.new(loc, aeon_locations: %w[aeonloc])
      expect(policy.aeon?).to be true
      expect(policy.available_status_key).to eq :appointment
    end

    it 'respects injected settings for restricted libraries' do
      loc = Inventory::Location.new(
        library_code: 'ARCHLIB', library_name: 'Archives',
        location_code: 'arch', location_name: 'Archives'
      )
      settings = OpenStruct.new(
        fulfillment: OpenStruct.new(
          restricted_libraries: OpenStruct.new(
            hsp: 'HSPLIB', archives: 'ARCHLIB', libra: 'LIBRALIB', res_share: 'RESLIB'
          )
        ),
        locations: OpenStruct.new(
          aeon_sublocation_map: {},
          aeon_location_map: {}
        )
      )
      policy = described_class.new(loc, settings: settings)
      expect(policy.archives?).to be true
      expect(policy.available_status_key).to eq :unrequestable
      expect(policy.requires_authentication?).to be false
    end
  end
end
