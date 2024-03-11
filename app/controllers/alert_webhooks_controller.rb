# frozen_string_literal: true

# webhook alert controller
class AlertWebhooksController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  skip_before_action :verify_authenticity_token

  ALLOWED_HTML_TAGS = %w[p a strong em ul ol li].freeze

  def listen
    payload = JSON.parse(request.body.string)
    update_alert(payload)
  rescue JSON::ParserError => _e
    head(:unprocessable_entity)
  rescue ActiveRecord::RecordInvalid => _e
    # TODO: Notify of error
    head(:internal_server_error)
  end

  private

  def update_alert(payload)
    payload.each_key do |key|
      alert = Alert.find_by(scope: key)
      return head :not_found if alert.blank?

      alert.update(
        on: payload.dig(key, 'on'),
        text: sanitize(payload.dig(key, 'text'), tags: ALLOWED_HTML_TAGS)
      )
    end
    head :ok
  end
end
