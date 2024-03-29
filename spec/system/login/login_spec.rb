# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  let(:user) { build(:user) }

  context 'when logging in ' do
    before { visit login_path }

    context 'when user exists in Alma' do
      before do
        allow(User).to receive(:new).and_return(user)
        allow(user).to receive(:exists_in_alma?).and_return(true)
      end

      it 'renders the success message' do
        expect(page).to have_text(I18n.t('login.pennkey'))
        click_on(I18n.t('login.pennkey'))
        expect(page).to have_text(I18n.t('devise.omniauth_callbacks.success', kind: 'saml'))
      end
    end

    context 'when user does not exist in Alma' do
      before do
        allow(User).to receive(:new).and_return(user)
        allow(user).to receive(:exists_in_alma?).and_return(false)
      end

      it 'renders the failure message' do
        expect(page).to have_text(I18n.t('login.pennkey'))
        click_on(I18n.t('login.pennkey'))
        expect(page).to have_text(I18n.t('devise.omniauth_callbacks.alma_failure'))
      end
    end

    context 'when user is a courtesy borrower' do
      it 'they can navigate to the courtesy borrower login page' do
        expect(page).to have_button(I18n.t('login.alma.name'))
        click_on(I18n.t('login.alma.name'))
        expect(page).to have_text(I18n.t('login.alma.heading'))
      end
    end
  end

  context 'when logging in from a record page' do
    include_context 'with electronic journal record with 4 electronic entries'

    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(true)

      visit solr_document_path(electronic_journal_bib)
      visit login_path
    end

    it 'redirects to record page after login' do
      click_on I18n.t('login.pennkey')
      expect(page).to have_current_path(solr_document_path(electronic_journal_bib))
    end
  end
end
