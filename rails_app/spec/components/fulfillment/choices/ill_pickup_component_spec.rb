# frozen_string_literal: true

describe Fulfillment::Choices::IllPickupComponent, type: :components do
  let(:user) { create :user }

  before { render_inline(described_class.new(user: user)) }

  it 'renders ill pickup location codes' do
    vp_locker_code = Settings.locations.pickup[:'Lockers at Van Pelt Library'].ill
    expect(page).to have_xpath("//select[@name=\"pickup_location\"]/option[@value=\"#{vp_locker_code}\"]")
  end
end
