# frozen_string_literal: true

require 'system_helper'

describe 'Account Settings show page' do
  let(:user) { build(:user) }

  context 'with a student user' do
    before do
      sign_in user

      # Stub Alma User
      alma_user = instance_double(Alma::User)
      allow(user).to receive(:alma_record).and_return(alma_user)
      allow(alma_user).to receive(:method_missing).with(:user_group).and_return({ 'desc' => 'undergraduate' })

      # Stub Illiad User
      illiad_user = build(:illiad_user, Address2: '123 private road / Philadelphia PA', Zip: '19104')
      allow(user).to receive(:illiad_record).and_return(illiad_user)

      visit settings_path
    end

    it 'shows user group' do
      expect(page).to have_text 'undergraduate'
    end

    it 'shows books by mail delivery address' do
      expect(page).to have_text '123 private road Philadelphia PA 19104'
    end
  end
end
