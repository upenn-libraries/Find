# frozen_string_literal: true

# handles requests from user login entrypoint
class LoginController < ApplicationController
  before_action :store_custom_redirect, if: :custom_redirect?

  def index; end

  def alma; end

  private

  # In order to anchor the user back to the request form when prompted to log in from
  # the catalog show page, we need the ability to pass and store a custom redirect path.
  # In the case of the catalog show page, we pass the param `custom_redirect` with the
  # original url + the anchor. Storing it here means we will redirect to that location
  # after a successful login.
  def store_custom_redirect
    store_location_for(:user, params[:custom_redirect])
  end

  # @return [Boolean]
  def custom_redirect?
    params[:custom_redirect].present?
  end
end
