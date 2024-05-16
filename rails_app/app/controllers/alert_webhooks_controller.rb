# frozen_string_literal: true

# webhook alert controller
class AlertWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  # Listens for and handles webhook events from Drupal
  def listen
    payload = JSON.parse(request.body.string)
    find_and_update_alert(payload)
  rescue JSON::ParserError => e
    Honeybadger.notify(e)
    head(:unprocessable_entity)
  rescue ActiveRecord::RecordInvalid => e
    Honeybadger.notify(e)
    head(:internal_server_error)
  end

  private

  # Find alert(s) based on incoming payload and update the values specified
  # @param [Hash] payload
  # @return [TrueClass]
  def find_and_update_alert(payload)
    payload.each_key do |scope|
      alert = Alert.find_by(scope: scope)
      return head :not_found if alert.blank?

      alert.update(
        on: confirm_on(payload.dig(scope, 'on'), payload.dig(scope, 'text')),
        text: payload.dig(scope, 'text')
      )
    end
    head :ok
  end

  # Ensure incoming payload contains token that matches stored token.
  def authenticate
    authenticate_or_request_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(token, Settings.alert_webhooks_token)
    end
  end

  # Don't turn the alert on if the incoming text is blank
  # @param [String] on
  # @param [String] text
  # @return [TrueClass, FalseClass]
  def confirm_on(on, text)
    return false if text.empty?

    on
  end
end
