# frozen_string_literal: true

require 'system_helper'

describe 'Account Settings show page' do
  let(:user) { create(:user) }
  let(:alma_user_data) { { user_group: { 'desc' => 'undergraduate' }, full_name: 'First Last' } }

  include_context 'with mock alma_record on user'

  before do
    login_as user

    # Stub Illiad User
    illiad_user = build(:illiad_user, Address2: '123 private road / Philadelphia PA', Zip: '19104')
    allow(user).to receive(:illiad_record).and_return(illiad_user)

    visit settings_path
  end

  it 'shows user group' do
    within('.table') do
      expect(page).to have_text 'undergraduate'
    end
  end

  it 'shows full name' do
    within('.table') do
      expect(page).to have_text('First Last')
    end
  end

  it 'shows email' do
    within('.table') do
      expect(page).to have_text(user.email)
    end
  end

  it 'shows books by mail delivery address' do
    expect(page).to have_text '123 private road Philadelphia PA 19104'
  end
end
