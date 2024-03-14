# frozen_string_literal: true

require 'system_helper'

describe 'alert display' do
  include FixtureHelpers

  before do
    allow(Rails.application.credentials).to receive(:alert_webhooks_token).and_return('1234')
    scopes.each { |scope| create(:alert, scope: scope) }
    post webhooks_alerts_path, params: json_fixture(fixture, :alert_webhooks), headers: { 'Token': '1234' }
    visit root_path
  end

  context 'with a general alert' do
    let(:scopes) { %w[alert] }
    let(:fixture) { 'general_updated' }

    it 'displays updated general alert' do
      within('div.webhook-alerts') do
        expect(page).to have_text 'General Alert'
      end
    end
  end

  context 'with a find only alert' do
    let(:scopes) { %w[find_only_alert] }
    let(:fixture) { 'find_only_updated' }

    it 'displays updated find only alert' do
      within('div.webhook-alerts') do
        expect(page).to have_text 'Find Only Alert'
      end
    end
  end

  context 'with both alerts' do
    let(:scopes) { %w[alert find_only_alert] }
    let(:fixture) { 'both_updated' }

    it 'displays both alerts' do
      within('div.alert') do
        expect(page).to have_selector('p', count: 2)
      end
    end
  end

  context 'with empty text and on set to true' do
    let(:scopes) { %w[alert] }
    let(:fixture) { 'empty_text_updated' }

    it 'does not display alert' do
      within('div.webhook-alerts') do
        expect(page).not_to have_selector('div.alert')
      end
    end
  end
end
