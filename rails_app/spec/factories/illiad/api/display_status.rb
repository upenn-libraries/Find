# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_api_display_status_response, class: Hash do
    sequence(:Id) { |num| num }
    add_attribute(:TransactionStatus) { 'Jim MW Processing' }
    add_attribute(:DisplayStatus) { 'In Process' }

    skip_create
    initialize_with { attributes }
  end
end
