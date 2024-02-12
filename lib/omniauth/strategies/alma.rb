# frozen_string_literal: true

require 'omniauth'

module OmniAuth
  module Strategies
    # Omniauth Strategy to support authenticating courtesy borrowers using Alma user credentials
    class Alma
      include OmniAuth::Strategy

      option :params, { email: :email, password: :password }
      option :uid_field, :email

      def request_phase
        redirect Rails.application.routes.url_helpers.alma_login_path
      end

      uid { email }

      info { { uid: email } }

      credentials { { user_id: email, password: password } }

      private

      # @return [String, Nil]
      def email
        request.params[options.params.email.to_s]
      end

      # @return [String, Nil]
      def password
        request.params[options.params.password.to_s]
      end
    end
  end
end
