# frozen_string_literal: true

# Parent controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout
  after_action :store_fullpath, unless: :should_not_store_action?
  after_action :store_referer, if: :login_path?

  # In this application, it is important to redirect a user back to where they come from after they log in.
  # To do this, we use some built in Devise helpers to save a load stored locations. For example, if a user has
  # clicked on a record and realizes they must sign in to use the email tool, we don't want them to
  # lose the record page they were on after they sign on. However, there are some URLs that we don't want to
  # store and redirect back to. We prefer to use the request referer if it's present, but default to the fullpath in
  # the event that it isn't.
  #
  # For more information on why request.referer can't be used by default, refer to the Devise wiki:
  # https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D#why-not-use-requestreferer

  # Always store the full path from the request, as this is present in every request.
  # @return [String]
  def store_fullpath
    store_location_for(:user, request.fullpath)
  end

  # Store the request referer if it's present. In our specific use case with the login page, we add query parameters
  # to the URL to ensure that the user is redirected back to the correct holding and with the request options expanded.
  # The request fullpath will not preserve these query parameters, so it's important that we prefer the request referer
  # in this specific use case.
  # @return [String, NilClass]
  def store_referer
    return unless referer_present?

    store_location_for(:user, request.referer)
  end

  private

  # Determine whether the current path is the login path
  # @return [TrueClass, FalseClass]
  def login_path?
    request.path == login_path
  end

  # Determine whether the request referer is present
  # @return [TrueClass, FalseClass]
  def referer_present?
    request.referer.present?
  end

  # Its important that the location is NOT stored if the request:
  # - method is not GET (non idempotent)
  # - is navigational
  # - is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #   infinite redirect loop.
  # - is an Ajax request as this can lead to very unexpected behaviour.
  # - is a Turbo Frame request
  # - is the login path - this is necessary because we have an extra page in between the referer and the Omniauth
  #   login strategy. Without this, a user would just end up back on the login page after they sign in.
  # - is the alma login path - same as above
  # - is to the inventory system - we make a lot of requests to our inventory system to display availability info.
  #   Without this exclusion, we could end up getting redirected to one of those inventory URLs.
  #
  # In some cases we may find it necessary to add to this list of exclusions. For example, if another login strategy
  # is added with a new login path, we'd want to stick that here. If we develop another service that makes a lot of
  # requests to another internal endpoint, that might be necessary to add.
  def should_not_store_action?
    !request.get? ||
      !is_navigational_format? ||
      devise_controller? ||
      request.xhr? ||
      turbo_frame_request? ||
      request.path == login_path ||
      request.path == alma_login_path ||
      request.path.ends_with?('inventory')
  end
end
