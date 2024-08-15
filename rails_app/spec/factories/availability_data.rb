# frozen_string_literal: true

FactoryBot.define do
  factory :electronic_availability_data, class: Hash do
    sequence(:num) { |n| n }

    portfolio_pid { "bogus-portfolio-#{num}" }
    collection_id { 'bogus-collection-id' }
    activation_status { Inventory::Constants::ELEC_AVAILABLE }
    library_code { 'VanPeltLib' }
    collection { 'Collection name' }
    public_note { 'Test Public Note' }
    coverage_statement { 'A coverage statement' }
    interface_name { "Bogus Portfolio #{num}" }
    inventory_type { Inventory::List::ELECTRONIC }

    trait :unavailable do
      activation_status { Inventory::Constants::ELEC_UNAVAILABLE }
    end

    skip_create
    initialize_with { attributes.stringify_keys }
  end

  factory :physical_availability_data, class: Hash do
    sequence(:num) { |n| n }

    holding_id { "bogus-holding-#{num}" }
    institution { '01UPENN_INST' }
    library_code { 'VanPeltLib' }
    location { 'Stacks' }
    call_number { "HQ801 .D43 1997 Copy #{num}" }
    availability { Inventory::Constants::AVAILABLE }
    total_items { '1' }
    non_available_items { '0' }
    location_code { 'vanp' }
    call_number_type { '0' }
    priority { '1' }
    library { 'Van Pelt Library' }
    inventory_type { Inventory::List::PHYSICAL }

    skip_create
    initialize_with { attributes.stringify_keys }

    trait :in_temp_location do
      location_code { 'vanpnewbook' }
      location { 'New Book Shelf' }
      holding_id { nil }
    end
  end

  factory(:item_data, class: Hash) do
    physical_material_type do
      { 'value' => 'BOOK', 'desc' => 'Book' }
    end
    policy do
      { 'value' => 'book/seria', 'desc' => 'Book/serial' }
    end

    skip_create
    initialize_with { attributes.stringify_keys }
  end

  factory(:ecollection_data, class: Hash) do
    id { '61570554750003689' }
    public_name { 'Oxford Handbooks Online Sociology' }
    public_name_override { 'Handbook - Sociology' }
    url { 'https://www.vendor.com/pages/resource' }
    url_override { 'https://hdl.library.upenn.edu/custom/url' }
    authentication_note { 'Ecollection authentication note' }
    public_note { 'Ecollection public note' }

    skip_create
    initialize_with { attributes.stringify_keys }
  end

  factory(:resource_link_data, class: Hash) do
    sequence(:num) { |n| n }

    link_text { "Part #{num}" }
    link_url { "https://www.colenda.com/record/#{num}/" }

    skip_create
    initialize_with { attributes }
  end
end
