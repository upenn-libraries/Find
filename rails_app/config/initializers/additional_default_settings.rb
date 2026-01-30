# frozen_string_literal: true

# Load additional default yml configuration files first so they are properly overridden in environment settings files
Dir[Rails.root.join('config/settings/additional_default_settings/*.yml')].each do |path|
  Settings.prepend_source! path
  Settings.reload!
end
