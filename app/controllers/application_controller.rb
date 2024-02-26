# frozen_string_literal: true

# Parent controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  def guest_user_params
    { provider: 'guest', uid: 'guest' }
  end
end
