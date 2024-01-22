# frozen_string_literal: true

module Users
  # custom Omniauth callbacks
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: %i[developer failure]

    def developer
      auth_request = request.env['omniauth.auth']
      if registered_in_alma?(auth_request['uid'])
        @user = User.from_omniauth(auth_request)
        handle_user(user: @user, kind: 'developer')
      else
        redirect_to login_path
        set_flash_message(:alert, :alma_failure)
      end
    end

    def saml
      auth_request = request.env['omniauth.auth']
      if registered_in_alma?(auth_request['uid'])
        @user = User.from_omniauth(request.env['omniauth.auth'])
        handle_user(user: @user, kind: 'saml')
      else
        redirect_to login_path
        set_flash_message(:alert, :alma_failure)
      end
    end

    def failure
      flash.alert = 'Problem with authentication, try again.'
      redirect_to root_path
    end

    private

    # @param [User] user
    # @param [String] kind
    def handle_user(user:, kind:)
      if !user
        redirect_to login_path
        set_flash_message :notice, :no_access
      elsif user.save
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        set_flash_message(:notice, :failure, kind: kind, reason: user.errors.to_a.join(', ')) if is_navigational_format?
        redirect_to login_path
      end
    end

    def registered_in_alma?(uid)
      user = Alma::User.find(uid)
      user.instance_of?(Alma::User)
    rescue Alma::User::ResponseError
      false
    end
  end
end
