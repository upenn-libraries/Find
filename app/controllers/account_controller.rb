# frozen_string_literal: true

# Parent controller for all Account-related controllers.
class AccountController < ApplicationController
  before_action :authenticate_user!
end
