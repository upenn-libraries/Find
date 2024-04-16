# frozen_string_literal: true

module Account
  # Controller for user-profile-related actions.
  class ProfileController < AccountController
    # GET /account/profile
    # Show user details (user group, addresses, service eligibility, fines/fees form Alma)
    def show; end

    # GET /account/profile/edit
    # Form to allow users to change editable information.
    def edit; end

    # PATCH /account/profile
    # Update user data in Alma (Illiad API offers no user update capability).
    def update; end
  end
end
