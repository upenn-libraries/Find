# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  context 'when user exists in Alma' do
    before do
      visit login_path
      allow_any_instance_of(User).to receive(:exists_in_alma?).and_return(true)
    end

    it 'renders the page' do
      expect(page).to have_text('Continue with PennKey')
      click_on ('Continue with PennKey')
      expect(page).to have_text('Successfully authenticated from saml account.')
    end
  end

  context 'when user does not exist in Alma' do
    before do
      visit login_path
      allow_any_instance_of(User).to receive(:exists_in_alma?).and_return(false)
    end

    it 'renders the page' do
      expect(page).to have_text('Continue with PennKey')
      click_on ('Continue with PennKey')
      expect(page).to have_text('not registered in our library system')
    end
  end
end
