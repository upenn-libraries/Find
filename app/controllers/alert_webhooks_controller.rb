# frozen_string_literal: true

# webhook alert controller
class AlertWebhooksController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :validate, only: [:listen]

  ALLOWED_HTML_TAGS = %w[p a strong em ul ol li].freeze

  # Listens for and handles webhook events from Drupal
  def listen
    payload = JSON.parse(request.body.string)
    find_and_update_alert(payload)
  rescue JSON::ParserError => _e
    # TODO: notify with honeybadger
    head(:unprocessable_entity)
  rescue ActiveRecord::RecordInvalid => _e
    # TODO: notify with honeybadger
    head(:internal_server_error)
  end

  private

  # @param [Hash] payload
  # @return [TrueClass]
  def find_and_update_alert(payload)
    payload.each_key do |scope|
      alert = Alert.find_by(scope: scope)
      return head :not_found if alert.blank?

      alert.update(
        on: payload.dig(scope, 'on'),
        text: sanitize(payload.dig(scope, 'text'), tags: ALLOWED_HTML_TAGS)
      )
    end
    head :ok
  end

  # Check request header token against rails credentials
  # @return [Boolean]
  def valid_token?
    token = request.get_header('Token') || request.get_header('HTTP_TOKEN')
    token == Rails.application.credentials.alert_webhooks_token
  end

  # Validates alert webhook post requests
  # @return [Boolean]
  def validate
    valid_token? || head(:unauthorized)
  end
end
