# frozen_string_literal: true

FactoryBot.define do
  # attributes for Alma User Api version 1
  factory :alma_user_response, class: Hash do
    status { { 'value' => 'ACTIVE', 'desc' => 'Active' } }
    primary_id { '12345678' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    user_group { { 'value' => 'undergrad', 'desc' => 'Undergraduate Student' } }
    user_statistic do
      [
        { 'statistic_category' => { 'value' => 'STU', 'desc' => 'Student' },
          'category_type' => { 'value' => 'AFFILIATION', 'desc' => '' } }
      ]
    end

    skip_create
    initialize_with { attributes }
  end
end
