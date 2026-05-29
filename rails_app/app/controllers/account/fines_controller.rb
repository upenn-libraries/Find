# frozen_string_literal: true

module Account
  # Controller for user-fines-related actions.
  class FinesController < AccountController
    before_action :authenticate_user!

    # GET /account/fines-and-fees
    def index; end
  end
end
