# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  let(:user) { build(:user) }

  before { visit login_path }

  context 'when user exists in Alma' do
    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(true)
    end

    it 'renders the success message' do
      expect(page).to have_text('Continue with PennKey')
      click_on('Continue with PennKey')
      expect(page).to have_text('Successfully authenticated from saml account.')
    end
  end

  context 'when user does not exist in Alma' do
    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(false)
    end

    it 'renders the failure message' do
      expect(page).to have_text('Continue with PennKey')
      click_on('Continue with PennKey')
      expect(page).to have_text('not registered in our library system')
    end
  end

  context 'when user is a courtesy borrower' do
    it 'they can navigate to the courtesy borrower login page' do
      expect(page).to have_button(I18n.t('login.borrower.name'))
      click_on(I18n.t('login.borrower.name'))
      expect(page).to have_text(I18n.t('login.borrower.heading'))
    end
  end
end
