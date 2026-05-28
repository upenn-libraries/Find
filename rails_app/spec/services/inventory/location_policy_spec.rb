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

end
