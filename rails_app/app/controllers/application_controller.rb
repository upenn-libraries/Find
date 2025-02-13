# frozen_string_literal: true

# Parent controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout
  after_action :store_fullpath, unless: :should_not_store_action?
  after_action :store_referer, unless: :should_not_store_referer?

  MAX_PATH_SIZE_TO_STORE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2

  # In this application, it is important to redirect a user back to where they come from after they log in.
  # To do this, we use some built in Devise helpers to save a load stored locations. For example, if a user has
  # clicked on a record and realizes they must sign in to use the email tool, we don't want them to
  # lose the record page they were on after they sign on. However, there are some URLs that we don't want to
  # store and redirect back to. We prefer to use the request referer if it's present, but default to the fullpath in
  # the event that it isn't.
  #
  # For more information on why request.referer can't be used by default, refer to the Devise wiki:
  # https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D#why-not-use-requestreferer

  # Always store the full path from the request, as this is present in every request. For catalog requests, we remove
  # blank parameters to mitigate storing very long values.
  # @return [String]
  def store_fullpath
    return store_location_for(:user, request.fullpath) unless catalog_path?

    uri = URI.parse(request.path)

    uri.query = catalog_params.to_query
    store_location_for(:user, uri.to_s)
  end

  # Store the request referer if it's present and if its pointing at the same path of current stored location. We need
  # this functionality because we use javascript to add query parameters to the URL to add certain features like,
  # ensuring that the user is redirected back to the correct holding. The stored location will not preserve these query
  # parameters because they are added on the client side, so it's important that we prefer the request referer in
  # this specific use case.
  # @return [String, NilClass]
  def store_referer
    return unless referer_present?

    # Need to cache stored location, otherwise it's deleted.
    current_stored_location = stored_location_for(:user)

    return if current_stored_location.nil?

    if URI.parse(current_stored_location).path == URI.parse(request.referer).path
      # Stored location and referrer have the same path. Prefer referer because it may contain query
      # params (like those added on show page interactions).
      store_location_for(:user, request.referer)
    else
      # Retain Devise's stored location, so the user is redirected to their expected destination after
      # logging in.
      store_location_for(:user, current_stored_location)
    end
  end

  private

  # Determine whether the current path is the login path
  # @return [Boolean]
  def login_path?
    request.path == login_path
  end

  # Determine whether the current path is a potential catalog path
  # @return [Boolean]
  def catalog_path?
    request.path == root_path || request.path.starts_with?(search_catalog_path)
  end

  # Determine whether the current path is a sitemap path
  # @return [Boolean]
  def sitemap_path?
    request.path.include? 'sitemap'
  end

  # Determine whether the request referer is present
  # @return [Boolean]
  def referer_present?
    request.referer.present?
  end

  # Determine whether fullpath exceeds max cookie size
  # @return [Boolean]
  def path_too_large?(path)
    return false unless path

    path.size >= MAX_PATH_SIZE_TO_STORE
  end

  # Do not store the referer if:
  # - not the login path
  # - referer is not present
  # - referer path is too large
  # @return [Boolean]
  def should_not_store_referer?
    sitemap_path? ||
      !login_path? ||
      !referer_present? ||
      path_too_large?(URI.parse(request.referer).path)
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
  # - is too large
  #
  # In some cases we may find it necessary to add to this list of exclusions. For example, if another login strategy
  # is added with a new login path, we'd want to stick that here. If we develop another service that makes a lot of
  # requests to another internal endpoint, that might be necessary to add.
  # @return [Boolean]
  def should_not_store_action?
    !request.get? ||
      !is_navigational_format? ||
      devise_controller? ||
      request.xhr? ||
      turbo_frame_request? ||
      request.path == login_path ||
      request.path == alma_login_path ||
      request.path.ends_with?('inventory') ||
      path_too_large?(request.fullpath)
  end

  # Remove blank catalog parameters to reduce request URL length before saving to session
  # - allow blank 'all_fields_advanced' advanced search clause parameter to ensure we always store a url that has the
  # necessary parameters to make a solr request
  # @return [ActionController::Parameters]
  def catalog_params
    catalog_params = params.permit(blacklight_config.search_state_fields, :hld_id, :request, f: {}, f_inclusive: {})
                           .except(:action, :controller).compact_blank

    clause_params = catalog_params['clause']

    return catalog_params if clause_params.blank?

    catalog_params['clause'] = clause_params.reject { |_, v| v['query'].blank? && v['field'] != 'all_fields_advanced' }

    catalog_params
  end
end
