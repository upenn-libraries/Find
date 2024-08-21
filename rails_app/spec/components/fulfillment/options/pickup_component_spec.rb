# frozen_string_literal: true

describe Fulfillment::Options::PickupComponent, type: :components do
  let(:user) { create :user }

  context 'when rendering alma pickup option' do
    before { render_inline(described_class.new(user: user)) }

    it 'render alma pickup location codes' do
      vp_locker_code = Settings.locations.pickup[:'Lockers at Van Pelt Library'].ils
      expect(page).to have_xpath("//select[@name=\"pickup_location\"]/option[@value=\"#{vp_locker_code}\"]")
    end
  end

  context 'when rendering ill pickup option' do
    before { render_inline(described_class.new(user: user, ill: true)) }

    it 'renders ill pickup location codes' do
      vp_locker_code = Settings.locations.pickup[:'Lockers at Van Pelt Library'].ill
      expect(page).to have_xpath("//select[@name=\"pickup_location\"]/option[@value=\"#{vp_locker_code}\"]")
    end
  end
end
