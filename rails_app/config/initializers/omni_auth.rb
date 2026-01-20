# frozen_string_literal: true

# Instead of using the omniauth-rails_csrf_protection gem, use this configuration to mitigate CVE-2015-9284
# As recommended by the authors of that gem. This requires omniauth gem > v2.0.0

OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
