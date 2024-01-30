# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      identifier { Faker::Name.unique.first_name.downcase }
    end

    provider { 'test' }
    uid { identifier }
    email { "#{identifier}@upenn.edu" }
  end
end
