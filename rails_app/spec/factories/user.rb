# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      identifier { Faker::Name.unique.first_name.downcase }
    end

    provider { 'test' }
    uid { identifier }
    email { "#{identifier}@upenn.edu" }
    ils_group { 'undergrad' }
  end

  trait :alma_authenticated do
    transient do
      identifier { Faker::Internet.email }
    end

    provider { 'alma' }
    uid { identifier }
    email { identifier }
  end

  trait :library_staff do
    ils_group { User::LIBRARY_STAFF_GROUP }
  end

  trait :courtesy_borrower do
    ils_group { User::COURTESY_BORROWER_GROUP }
  end
end
