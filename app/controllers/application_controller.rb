# frozen_string_literal: true

# Parent controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout
  after_action :store_action


  # Its important that the location is NOT stored if the request:
  # - method is not GET (non idempotent)
  # - is navigational
  # - is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #   infinite redirect loop.
  # - is an Ajax request as this can lead to very unexpected behaviour.
  # - is a Turbo Frame request
  # - is the login path
  # - is the alma login path
  # - is to the inventory system
  def store_action
    return unless request.get?
    return unless is_navigational_format?
    return if devise_controller?
    return if request.xhr?
    return if turbo_frame_request?
    return if request.path == login_path
    return if request.path == alma_login_path
    return if request.path.ends_with? '/inventory'

    store_location_for(:user, request.fullpath)
  end
end
