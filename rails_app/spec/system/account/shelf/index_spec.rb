# frozen_string_literal: true

require 'system_helper'

describe 'Account Shelf index page' do
  let(:user) { build(:user) }
  # let(:alma_user_data) { { user_group: { 'desc' => 'undergraduate' }, full_name: 'First Last' } }
  #
  # include_context 'with mock alma_record on user'
  let(:shelf_listing) do
    create(:shelf_listing)
  end

  before do
    sign_in user

    # Stub Shelf Listing
    shelf = instance_double(Shelf::Service)
    allow(Shelf::Service).to receive(:new).with(user.id).and_return(shelf)
    allow(shelf).to receive(:find_all).and_return(shelf_listing)

    visit requests_path
  end

  it 'displays all entries'

  context 'when displaying loans' do
    it 'shows all expected information'

    it 'show renew all button'
  end

  context 'when display ill transaction' do
    it 'shows all expected information'
  end

  context 'when displaying hold' do
    it 'shows all expected information'
  end
end
