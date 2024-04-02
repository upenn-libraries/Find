# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_user, class: 'Illiad::User' do
    sequence(:UserName) { |n| "testuser#{n}" }

    skip_create
    initialize_with { Illiad::User.new(**attributes) }
  end
end
