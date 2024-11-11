# frozen_string_literal: true

describe Fulfillment::OptionsSet do
  subject(:options) { described_class.new(item: item, user: user) }

  let(:user) { build(:user) }

  context 'with an available circulating item' do
    let(:item) { build :item, *traits }
    let(:traits) { [] }

    it { is_expected.to be_deliverable }
    it { is_expected.not_to be_unavailable }
    it { is_expected.not_to be_restricted }

    context 'with a standard user' do
      it 'includes scan, pickup and delivery options' do
        expect(options.to_a).to match_array [Fulfillment::Options::Deliverable::PICKUP,
                                             Fulfillment::Options::Deliverable::MAIL,
                                             Fulfillment::Options::Deliverable::ELECTRONIC]
      end
    end

    context 'with a courtesy borrower user' do
      let(:user) { build(:user, :courtesy_borrower) }

      it 'includes only a pickup option' do
        expect(options.to_a).to eq [Fulfillment::Options::Deliverable::PICKUP]
      end
    end

    context 'with a faculty express user' do
      let(:user) { build(:user, :faculty_express) }

      it 'includes office delivery option' do
        expect(options.to_a).to include Fulfillment::Options::Deliverable::OFFICE
      end
    end

    context 'with an item with a material type that cannot be processed via Books by Mail' do
      let(:traits) { [:laptop_material_type] }

      it 'does not include delivery option' do
        expect(options.to_a).not_to include Fulfillment::Options::Deliverable::MAIL
      end
    end

    context 'with an item with a material type that cannot be electronically delivered' do
      let(:traits) { [:laptop_material_type] }

      it 'does not include electronic option' do
        expect(options.to_a).not_to include Fulfillment::Options::Deliverable::ELECTRONIC
      end
    end
  end

  context 'with an unavailable item' do
    let(:item) { build :item, :not_in_place }

    it { is_expected.to be_unavailable }
    it { is_expected.not_to be_restricted }
    it { is_expected.not_to be_deliverable }
  end

  context 'with an item on reserves' do
    let(:item) { build :item, :on_reserve }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_unavailable }
    it { is_expected.not_to be_deliverable }

    it 'includes only the reserves option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::RESERVES]
    end
  end

  context 'with an item having a non-circ policy' do
    let(:item) { build :item, :non_circ }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_unavailable }
    it { is_expected.not_to be_deliverable }

    it 'includes only the on site option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::ONSITE]
    end
  end
end
