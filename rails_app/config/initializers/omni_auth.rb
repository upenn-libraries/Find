# frozen_string_literal: true

# Instead of using the omniauth-rails_csrf_protection gem, use this configuration to mitigate CVE-2015-9284
# As recommended by the authors of that gem. This requires omniauth gem > v2.0.0. Rails disables CSRF protection
# mechanisms in test so disable this in test env.

OmniAuth.config.request_validation_phase =
  if Rails.env.test?
    nil
  else
    OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
  end
