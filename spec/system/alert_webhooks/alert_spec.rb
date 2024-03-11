# frozen_string_literal: true

require 'system_helper'

describe 'alert display' do
  include FixtureHelpers

  before do
    allow(Rails.application.credentials).to receive(:alert_webhooks_token).and_return('1234')
  end

  context 'with a general alert' do
    before do
      create(:alert, scope: 'alert', text: '<p>Original General Alert</p>')
      post webhooks_alerts_path, params: json_fixture('general_updated', :alert_webhooks),
                                 headers: { 'Token': '1234' }
      visit root_path
    end

    it 'displays updated general alert' do
      within('div.webhook-alerts') do
        expect(page).to have_text 'General Alert'
      end
    end
  end

  context 'with a find only alert' do
    before do
      create(:alert, scope: 'find_only_alert', text: '<p>Original Find Alert</p>')
      post webhooks_alerts_path, params: json_fixture('find_only_updated', :alert_webhooks),
                                 headers: { 'Token': '1234' }
      visit root_path
    end

    it 'displays updated find only alert' do
      within('div.webhook-alerts') do
        expect(page).to have_text 'Find Only Alert'
      end
    end
  end

  context 'with both alerts' do
    before do
      create(:alert, scope: 'alert')
      create(:alert, scope: 'find_only_alert')
      post webhooks_alerts_path, params: json_fixture('both_updated', :alert_webhooks),
                                 headers: { 'Token': '1234' }
      visit root_path
    end

    it 'displays both alerts' do
      within('div.webhook-alerts') do
        expect(page).to have_selector('div.alert', count: 2)
      end
    end
  end
end
