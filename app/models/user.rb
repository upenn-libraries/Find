# frozen_string_literal: true

# User model
class User < ApplicationRecord
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # if we want rememberable, we have to do a DB migration to include t.datetime "remember_created_at"
  # devise :rememberable, :timeoutable
  devise :timeoutable
  if Rails.env.development?
    devise :omniauthable, omniauth_providers: %i[developer saml]
  else
    devise :omniauthable, omniauth_providers: %i[saml]
  end

  validates :email, presence: true, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }, if: :provider_provided?

  def self.from_omniauth(auth)
    email = "#{auth.info.email}@upenn.edu"
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = email
    end
  end

  def exists_in_alma?
    user = Alma::User.find(uid)
    user.instance_of?(Alma::User)
  rescue Alma::User::ResponseError
    false
  end

  # Configuration added by Blacklight; Blacklight::User uses a method key on your
  # user class to get a user-displayable login/identifier for
  # the account.
  self.string_display_key ||= :email

  private

  # @return [TrueClass, FalseClass]
  def provider_provided?
    provider.present?
  end
end
