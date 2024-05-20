# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  let(:user) { build(:user) }
  let(:alma_user_group) { { 'value' => 'patron' } }

  include_context 'with User.new returning user'

  context 'when logging in ' do
    before { visit login_path }

    context 'when user exists in Alma' do
      include_context 'with mock alma_record on user having alma_user_group user group'

      it 'renders the success message' do
        expect(page).to have_text(I18n.t('login.pennkey'))
        click_on(I18n.t('login.pennkey'))
        expect(page).to have_text(I18n.t('devise.omniauth_callbacks.success',
                                         kind: I18n.t('devise.omniauth_callbacks.saml_kind')))
      end
    end

    context 'when user does not exist in Alma' do
      include_context 'with user alma_record lookup returning false'

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
    include_context 'with mock alma_record on user having alma_user_group user group'

    before do
      visit solr_document_path(electronic_journal_bib)
      visit login_path
    end

    it 'redirects to record page after login' do
      click_on I18n.t('login.pennkey')
      expect(page).to have_current_path(solr_document_path(electronic_journal_bib))
    end
  end
end
