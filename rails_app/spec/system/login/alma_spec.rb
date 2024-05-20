# frozen_string_literal: true

require 'system_helper'

describe 'index page' do
  let(:user) { build(:user, :alma_authenticated) }
  let(:alma_user_group) { { 'value' => 'patron' } }

  include_context 'with User.new returning user'
  include_context 'with mock alma_record on user having alma_user_group user group'

  before { visit alma_login_path }

  context 'when Alma authentication succeeds' do
    before do
      allow(User).to receive(:authenticated_by_alma?).and_return(true)
    end

    it 'renders success message' do
      fill_in :email, with: user.email
      fill_in :password, with: '123456789'
      click_on I18n.t('login.alma.login')
      expect(page).to have_text(I18n.t('devise.omniauth_callbacks.success',
                                       kind: I18n.t('devise.omniauth_callbacks.alma_kind')))
    end
  end

  context 'when Alma authentication fails' do
    before do
      allow(User).to receive(:authenticated_by_alma?).and_return(false)
    end

    it 'renders failure message' do
      fill_in :email, with: user.email
      fill_in :password, with: '123456789'
      click_on I18n.t('login.alma.login')
      expect(page).to have_text(I18n.t('devise.omniauth_callbacks.alma_failure'))
    end
  end
end
