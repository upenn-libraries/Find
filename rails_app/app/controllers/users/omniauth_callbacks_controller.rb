# frozen_string_literal: true

module Users
  # custom Omniauth callbacks
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: %i[developer failure]

    def developer
      user = User.from_omniauth_developer(request.env['omniauth.auth'])
      alma_user = user.alma_record
      if alma_user
        handle_user(user: user, alma_user: alma_user, kind: 'developer')
      else
        user.destroy if user.new_record?
        redirect_to login_path
        set_flash_message(:alert, :alma_failure)
      end
    end

    def saml
      user = User.from_omniauth_saml(request.env['omniauth.auth'])
      alma_user = user.alma_record
      if alma_user
        handle_user(user: user, alma_user: alma_user, kind: 'saml')
      else
        user.destroy if user.new_record?
        redirect_to login_path
        set_flash_message(:alert, :alma_failure)
      end
    end

    def alma
      if User.authenticated_by_alma?(request.env['omniauth.auth'].credentials)
        user = User.from_omniauth_alma(request.env['omniauth.auth'])
        handle_user(user: user, alma_user: user.alma_record, kind: 'alma')
      else
        redirect_to alma_login_path
        set_flash_message(:alert, :alma_failure)
      end
    end

    def failure
      flash.alert = 'Problem with authentication, try again.'
      redirect_to root_path
    end

    private

    # @param [User] user
    # @param alma_user [Alma::User]
    # @param [String] kind
    def handle_user(user:, alma_user:, kind:)
      user.ils_group = alma_user.user_group['value']
      if user.save
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        set_flash_message(:notice, :failure, kind: kind, reason: user.errors.to_a.join(', ')) if is_navigational_format?
        redirect_to login_path
      end
    end
  end
end
