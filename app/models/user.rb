# frozen_string_literal: true

# User model
class User < ApplicationRecord
  include Blacklight::User

  devise :timeoutable
  if Rails.env.development?
    devise :omniauthable, omniauth_providers: %i[developer alma saml]
  else
    devise :omniauthable, omniauth_providers: %i[alma saml]
  end

  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: :provider_provided?
  validates :provider, presence: true, if: :uid_provided?

  # Configuration added by Blacklight; Blacklight::User uses a method key on your user class to get a user-displayable
  # login/identifier for the account.
  self.string_display_key ||= :email

  # @param [OmniAuth::AuthHash] auth
  # @return [User, nil]
  def self.from_omniauth_saml(auth)
    where(provider: auth.provider, uid: auth.info.uid.gsub('@upenn.edu', '')).first_or_initialize do |user|
      user.email = auth.info.uid
    end
  end

  # @param [OmniAuth::AuthHash] auth
  # @return [User]
  def self.from_omniauth_developer(auth)
    return unless Rails.env.development?

    email = "#{auth.info.uid}@upenn.edu"
    where(provider: auth.provider, uid: auth.info.uid).first_or_initialize do |user|
      user.email = email
    end
  end

  # @param [OmniAuth::AuthHash] auth
  # @return [User]
  def self.from_omniauth_alma(auth)
    where(provider: auth.provider, uid: auth.info.uid).first_or_initialize do |user|
      user.email = auth.info.uid
    end
  end

  # @param [Hash] credentials
  # @return [Boolean]
  def self.authenticated_by_alma?(credentials)
    Alma::User.authenticate(credentials)
  rescue StandardError
    false
  end

  # @return [Alma::User, FalseClass]
  def alma_record
    @alma_record ||= begin
      Alma::User.find(uid)
    rescue Alma::User::ResponseError
      false
    end
  end

  # @return [Illiad::User, FalseClass]
  def illiad_record
    @illiad_record ||= begin
      Illiad::User.find(id: uid)
    rescue Illiad::Client::Error
      false
    end
  end

  private

  # @return [TrueClass, FalseClass]
  def provider_provided?
    provider.present?
  end

  # @return [TrueClass, FalseClass]
  def uid_provided?
    uid.present?
  end
end
