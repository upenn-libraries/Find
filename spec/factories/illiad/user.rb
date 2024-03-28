# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_user, class: 'Illiad::User' do
    data { FactoryBot.build(:illiad_user_data) }

    skip_create
    initialize_with { Illiad::User.new(data: data) }
  end
end
