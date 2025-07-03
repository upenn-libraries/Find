# frozen_string_literal: true

describe Fulfillment::OptionsSet do
  subject(:options) { described_class.new(item: item, user: user) }

  let(:user) { build(:user) }

  before { allow(user).to receive(:ill_blocked?).and_return false }

  context 'with an available circulating item' do
    let(:item) { build :item, *traits }
    let(:traits) { [] }

    it { is_expected.to be_deliverable }
    it { is_expected.not_to be_restricted }

    context 'with a standard user' do
      it 'includes scan, pickup and delivery options' do
        expect(options.to_a).to match_array [Fulfillment::Options::Deliverable::PICKUP,
                                             Fulfillment::Options::Deliverable::MAIL,
                                             Fulfillment::Options::Deliverable::ELECTRONIC]
      end
    end

    context 'with a standard user with an ILL block' do
      before { allow(user).to receive(:ill_blocked?).and_return true }

      it 'includes only pickup option' do
        expect(options.to_a).to match_array [Fulfillment::Options::Deliverable::PICKUP]
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

    context 'with a Not Loanable due date policy' do
      let(:traits) { [:not_loanable] }

      it { is_expected.not_to be_deliverable }
      it { is_expected.to be_restricted }

      it 'includes only the on site option' do
        expect(options.to_a).to eq [Fulfillment::Options::Restricted::ONSITE]
      end
    end
  end

  context 'with an unavailable item' do
    context 'with a standard item' do
      let(:item) { build :item, :not_in_place }

      it { is_expected.not_to be_restricted }
      it { is_expected.to be_deliverable }

      it 'includes the ILL_PICKUP option' do
        expect(options.to_a).to include Fulfillment::Options::Deliverable::ILL_PICKUP
        expect(options.to_a).not_to include Fulfillment::Options::Deliverable::PICKUP
      end
    end

    context 'with a non-circulating policy' do
      let(:item) { build :item, :not_in_place_non_circulating }

      it { is_expected.not_to be_restricted }
      it { is_expected.to be_deliverable }

      it 'includes the ILL_PICKUP option' do
        expect(options.to_a).to include Fulfillment::Options::Deliverable::ILL_PICKUP
        expect(options.to_a).not_to include Fulfillment::Options::Deliverable::PICKUP
      end
    end

    context 'with a Not Loanable due date policy and Not In Place' do
      let(:item) { build :item, :not_loanable_not_in_place }

      it { is_expected.not_to be_restricted }
      it { is_expected.to be_deliverable }

      it 'includes the ILL_PICKUP option' do
        expect(options.to_a).to include Fulfillment::Options::Deliverable::ILL_PICKUP
        expect(options.to_a).not_to include Fulfillment::Options::Deliverable::PICKUP
      end
    end

    context 'with an excluded material type item' do
      let(:item) { build :item, :laptop_material_type_not_in_place }

      it { is_expected.not_to be_restricted }
      it { is_expected.not_to be_deliverable }

      it 'does not include any options if the item cannot be processed via ILL' do
        expect(options.to_a).to be_empty
      end
    end
  end

  context 'with an item on reserve' do
    let(:item) { build :item, :on_reserve }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the reserve option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::RESERVE]
    end
  end

  context 'with an item having a non-circ policy' do
    let(:item) { build :item, :non_circ }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the on site option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::ONSITE]
    end
  end

  context 'with a restricted circ item that the Alma Request Options API says cannot be requested' do
    let(:item) { build :item, :in_place_with_restricted_short_loan_policy }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the on site option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::ONSITE]
    end
  end

  context 'with a non circ item that the Alma Request Options API says can be digitized' do
    let(:item) do
      build :item, :non_circ, request_options_list: [Settings.fulfillment.scan.request_option_indicators.sample]
    end

    it { is_expected.not_to be_restricted }
    it { is_expected.to be_deliverable }

    it 'includes only the scan option' do
      expect(options.to_a).to eq [Fulfillment::Options::Deliverable::ELECTRONIC]
    end
  end

  context 'with an item in an Aeon location' do
    let(:item) { build :item, :aeon_location }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the Aeon option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::AEON]
    end
  end

  context 'with an item located at HSP' do
    let(:item) { build :item, :at_hsp }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the HSP option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::HSP]
    end
  end

  context 'with an item located at the Archives' do
    let(:item) { build :item, :at_archives }

    it { is_expected.to be_restricted }
    it { is_expected.not_to be_deliverable }

    it 'includes only the Archives option' do
      expect(options.to_a).to eq [Fulfillment::Options::Restricted::ARCHIVES]
    end
  end
end
