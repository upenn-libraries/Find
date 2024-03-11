# frozen_string_literal: true

describe 'Alert Webhooks Requests' do
  include FixtureHelpers

  before do
    create(:alert, scope: 'alert')
    create(:alert, scope: 'find_only_alert')
  end

  context 'when receiving POST request' do
    it 'validates message integrity' do
      pending('header auth must be implemented')
      post webhooks_alerts_path, params: {}, headers: { 'signature': 'baaaaaaad' }
      expect(response).to have_http_status :unauthorized
    end

    it 'handles general alert updated event' do
      post webhooks_alerts_path, params: json_fixture('general_updated', :alert_webhooks)
      expect(response).to have_http_status :ok
    end

    it 'handles find only alert updated event' do
      post webhooks_alerts_path, params: json_fixture('find_only_updated', :alert_webhooks)
      expect(response).to have_http_status :ok
    end

    it 'handles invalid alert updated event' do
      post webhooks_alerts_path, params: json_fixture('invalid_updated', :alert_webhooks)
      expect(response).to have_http_status :not_found
    end
  end
end
