# frozen_string_literal: true

module Account
  # Controller for user-account-settings-related actions.
  class SettingsController < AccountController
    # GET /account/settings
    # Show user details (user group, addresses, service eligibility, fines/fees form Alma)
    def show; end

    # GET /account/settings/edit
    # Form to allow users to change editable information.
    def edit; end

    # PATCH /account/settings
    # Update user data in Alma (Illiad API offers no user update capability).
    def update; end
  end
end
