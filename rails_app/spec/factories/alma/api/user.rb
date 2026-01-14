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
    user_role { [] }

    skip_create
    initialize_with { attributes }

    trait :work_order_operator_active do
      user_role do
        [{ 'status' => { 'value' => 'ACTIVE', 'desc' => 'Active' },
           'scope' => { 'value' => '01UPENN_INST', 'desc' => 'University of Pennsylvania' },
           'role_type' => { 'value' => Settings.alma.work_order_role_value.to_s, 'desc' => 'Work Order Operator' },
           'parameter' => [] }]
      end
    end

    trait :work_order_operator_inactive do
      user_role do
        [{ 'status' => { 'value' => 'INACTIVE', 'desc' => 'Inactive' },
           'scope' => { 'value' => '01UPENN_INST', 'desc' => 'University of Pennsylvania' },
           'role_type' => { 'value' => Settings.alma.work_order_role_value.to_s, 'desc' => 'Work Order Operator' },
           'parameter' => [] }]
      end
    end
  end
end
