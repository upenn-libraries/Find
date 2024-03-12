# frozen_string_literal: true

describe 'Alert Webhooks Requests' do
  include FixtureHelpers

  before do
    create(:alert, scope: 'alert')
    create(:alert, scope: 'find_only_alert')
    allow(Rails.application.credentials).to receive(:alert_webhooks_token).and_return('1234')
  end

  context 'when receiving POST request' do
    it 'validates message integrity' do
      headers = { 'Token': 'baaaaaaad' }
      post webhooks_alerts_path, params: json_fixture('general_updated', :alert_webhooks), headers: headers
      expect(response).to have_http_status :unauthorized
    end

    it 'handles general alert updated event' do
      headers = { 'Token': '1234' }
      post webhooks_alerts_path, params: json_fixture('general_updated', :alert_webhooks), headers: headers
      expect(response).to have_http_status :ok
    end

    it 'handles find only alert updated event' do
      headers = { 'Token': '1234' }
      post webhooks_alerts_path, params: json_fixture('find_only_updated', :alert_webhooks), headers: headers
      expect(response).to have_http_status :ok
    end

    it 'handles invalid alert updated event' do
      headers = { 'Token': '1234' }
      post webhooks_alerts_path, params: json_fixture('invalid_updated', :alert_webhooks), headers: headers
      expect(response).to have_http_status :not_found
    end

    it 'handles bad JSON' do
      headers = { 'Token': '1234' }
      post webhooks_alerts_path, params: 'bad params', headers: headers
      expect(response).to have_http_status :unprocessable_entity
    end
  end
end
