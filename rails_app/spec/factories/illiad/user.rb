# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_user, class: 'Illiad::User' do
    sequence(:UserName) { |n| "testuser#{n}" }

    trait :with_office_address do
      add_attribute(:Address) { '123 College Hall' }
    end

    trait :with_office_and_bbm_address do
      with_bbm_address
      add_attribute(:Address) { 'D1234 Books by Mail/123 Williams Hall' }
    end

    trait :with_bbm_address do
      add_attribute(:Address) { 'D1234 Books by Mail' }
      add_attribute(:Address2) { '1 Smith St./Philadelphia, PA' }
      add_attribute(:Zip) { '12345' }
    end

    skip_create
    initialize_with { Illiad::User.new(**attributes) }
  end
end
