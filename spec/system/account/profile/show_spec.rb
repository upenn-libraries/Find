# frozen_string_literal: true

require 'system_helper'

describe 'Account Profile Show Page' do
  let(:user) { build(:user) }

  before do
    sign_in user
    # Stub Alma User
    alma_user = instance_double(Alma::User)
    allow(user).to receive(:alma_record).and_return(alma_user)
    allow(alma_user).to receive(:total_fines).and_return(100.0)
    allow(alma_user).to receive(:method_missing).with(:user_group).and_return({ 'desc' => 'undergraduate' })

    # Stub Illiad User
    illiad_user = build(:illiad_user, Address2: '123 private road / Philadelphia PA', Zip: '19104')
    allow(user).to receive(:illiad_record).and_return(illiad_user)
  end

  context 'with a student account' do
    before { visit profile_path }

    it 'shows total fines' do
      expect(page).to have_text '$100.0'
    end

    it 'shows user group' do
      expect(page).to have_text 'undergraduate'
    end

    it 'shows books by mail address' do
      expect(page).to have_text '123 private road Philadelphia PA 19104'
    end
  end
end
