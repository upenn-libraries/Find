# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  let(:user) { build(:user) }
  let(:alma_user_group) { { 'value' => 'patron' } }

  include_context 'with User.new returning user'

  context 'when logging in' do
    before { visit login_path }

    context 'when user exists in Alma' do
      include_context 'with mock alma_record on user having alma_user_group user group'

      it 'renders the success message' do
      it 'renders the success message', :flaky do
        expect(page).to have_text(I18n.t('login.pennkey'))
        click_on(I18n.t('login.pennkey'))
        expect(page).to have_text(I18n.t('devise.omniauth_callbacks.success',
                                         kind: I18n.t('devise.omniauth_callbacks.saml_display_value')))
      end
    end

    context 'when user does not exist in Alma' do
      include_context 'with user alma_record lookup returning false'

      it 'renders the failure message' do
        expect(page).to have_text(I18n.t('login.pennkey'))
        click_on(I18n.t('login.pennkey'))
        expect(page).to have_selector('div.alert', text: I18n.t('devise.omniauth_callbacks.alma_failure'))
      end
    end

    context 'when user is a courtesy borrower' do
      it 'they can navigate to the courtesy borrower login page', :flaky do
        expect(page).to have_button(I18n.t('login.alma.name'))
        click_on(I18n.t('login.alma.name'))
        expect(page).to have_selector('h1.page__heading', text: I18n.t('login.alma.heading'))
      end
    end
  end

  context 'when logging in from a record page' do
    include_context 'with print monograph record with 2 physical entries'
    include_context 'with mock alma_record on user having alma_user_group user group'
    include_context 'with empty hathi response'

    before do
      allow(Inventory::Item).to receive(:find_all).and_return([create(:item)])

      visit solr_document_path(print_monograph_bib)
      click_on I18n.t('requests.form.log_in_to_request_item')
      click_on I18n.t('login.pennkey')
    end

    it 'redirects to record page after login', :flaky do
      expect(page).to have_current_path(/^#{solr_document_path(print_monograph_bib)}/)
    end

    it 'adds request param to url', :flaky do
      expect(current_url).to include('request=true')
    end

    it 'expands the request options' do
      expect(page).to have_selector('details[open]')
    end
  end

  context 'when visiting a page that requires authentication' do
    include_context 'with mock alma_record on user having alma_user_group user group'

    let(:url_requested) { account_path }

    before { visit url_requested }

    it 'redirects to the login page' do
      expect(page).to have_current_path(login_path)
    end

    it 'after logging in redirects to url requested', :flaky do
      click_on I18n.t('login.pennkey')
      expect(page).to have_current_path(url_requested)
    end
  end
end
