# frozen_string_literal: true

FactoryBot.define do
  factory :electronic_availability_data, class: Hash do
    portfolio_pid { 'bogus-portfolio-pid' }
    collection_id { 'bogus-collection-id' }
    activation_status { Inventory::Constants::ELEC_AVAILABLE }
    library_code { 'VanPeltLib' }
    collection { 'Collection name' }
    public_note { 'Test Public Note' }
    coverage_statement { 'A coverage statement' }
    interface_name { 'An interface name' }
    inventory_type { Inventory::Entry::ELECTRONIC }

    trait :unavailable do
      activation_status { Inventory::Constants::ELEC_UNAVAILABLE }
    end

    skip_create
    initialize_with { attributes.stringify_keys }
  end

  factory :physical_availability_data, class: Hash do
    holding_id { 'test_holding_id' }
    institution { '01UPENN_INST' }
    library_code { 'VanPeltLib' }
    location { 'Stacks' }
    call_number { 'HQ801 .D43 1997' }
    availability { Inventory::Constants::AVAILABLE }
    total_items { '1' }
    non_available_items { '0' }
    location_code { 'vanp' }
    call_number_type { '0' }
    priority { '1' }
    library { 'Van Pelt Library' }
    inventory_type { Inventory::Entry::PHYSICAL }

    skip_create
    initialize_with { attributes.stringify_keys }
  end
end
