# frozen_string_literal: true

require 'system_helper'

describe 'alert display' do
  include FixtureHelpers

  before do
    allow(Settings).to receive(:alert_webhooks_token).and_return('1234')
    scopes.each { |scope| create(:alert, scope: scope) }
    post webhooks_alerts_path, params: json_fixture(fixture, :alert_webhooks),
                               headers: { 'Authorization': 'Bearer 1234' }
    visit root_path
  end

  context 'with a general alert' do
    let(:scopes) { %w[alert] }
    let(:fixture) { 'general_updated' }

    it 'displays updated general alert' do
      within('.site-alerts__container') do
        expect(page).to have_text 'General Alert'
      end
    end
  end

  context 'with a find only alert' do
    let(:scopes) { %w[find_only_alert] }
    let(:fixture) { 'find_only_updated' }

    it 'displays updated find only alert' do
      within('.site-alerts__container') do
        expect(page).to have_text 'Find Only Alert'
      end
    end
  end

  context 'with both alerts' do
    let(:scopes) { %w[alert find_only_alert] }
    let(:fixture) { 'both_updated' }

    it 'displays both alerts' do
      within('.site-alerts__container') do
        expect(page).to have_selector('p', count: 2)
      end
    end
  end

  context 'with empty text and on set to true' do
    let(:scopes) { %w[alert] }
    let(:fixture) { 'empty_text_updated' }

    it 'does not display alert' do
      within('.site-alerts__container') do
        expect(page).not_to have_selector('div.alert')
      end
    end
  end

  context 'when alerts are dismissed' do
    let(:scopes) { %w[alert find_only_alert] }
    let(:fixture) { 'both_updated' }
    let(:alert) { Alert.first }

    before do
      within('.site-alerts__container') do
        find('button.btn-close').click
      end
    end

    it 'dismisses the alert and persists on refresh' do
      within('.site-alerts__container') do
        expect(page).not_to have_selector('div.alert')
        refresh
        expect(page).not_to have_selector('div.alert')
      end
    end

    context 'when the alert is updated' do
      before do
        alert.updated_at = Time.current + 1.day
        alert.save
      end

      it 're-enables the alert' do
        within('.site-alerts__container') do
          expect(page).not_to have_selector('div.alert')
          refresh
          expect(page).to have_selector('div.alert')
        end
      end
    end
  end
end
