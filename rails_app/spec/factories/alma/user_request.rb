# frozen_string_literal: true

FactoryBot.define do
  factory :alma_user_request, aliases: [:alma_hold], class: 'Alma::UserRequest' do
    title { Faker::Book.title }
    author { Faker::Book.author }
    volume { '' }
    issue { '' }
    part { '' }
    barcode { '31198008228384' }
    user_primary_id { '123456' }
    request_id { '56352378420003681' }
    additional_id { '563-523-784-2' }
    request_type { 'HOLD' }
    request_sub_type { { 'value' => 'PATRON_PHYSICAL', 'desc' => 'Patron physical item request' } }
    mms_id { '991462123503681' }
    pickup_location { 'Van Pelt Library' }
    pickup_location_type { 'LIBRARY' }
    pickup_location_library { 'VanPeltLib' }
    managed_by_library { 'Van Pelt Library' }
    managed_by_circulation_desk { 'Van Pelt Stacks Circulation' }
    managed_by_library_code { 'VanPeltLib' }
    managed_by_circulation_desk_code { 'VPSTACKS' }
    material_type { {} }
    date_of_publication { '' }
    request_status { 'IN_PROCESS' }
    request_date { '2024-04-12Z' }
    request_time { '2024-04-12T15:33:37.258Z' }
    task_name { 'Pickup From Shelf' }
    expiry_date { '2024-04-20Z' }
    item_id { '23363685100003681' }

    trait :on_hold_shelf do
      request_status { 'ON_HOLD_SHELF' }
    end

    trait :resource_sharing do
      resource_sharing { {} } # TODO: Need to get some sample data.
    end

    skip_create
    initialize_with { Alma::UserRequest.new(attributes.deep_stringify_keys) }
  end
end
