# frozen_string_literal: true

# Alert dismissal controller
class AlertDismissController < ApplicationController
  # Dismiss alert
  def dismiss
    session[:alert_dismissed_at] = Time.current
  end
end
