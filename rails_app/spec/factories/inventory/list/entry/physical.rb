# frozen_string_literal: true

FactoryBot.define do
  factory :physical_entry, class: 'Inventory::List::Entry::Physical' do
    mms_id { '1234567890' }
    availability { Inventory::Constants::AVAILABLE }
    sequence(:call_number) { |n| "QD1 .C48 copy #{n}" }
    sequence(:holding_info) { |n| "1965-1971 copy #{n}" }
    library_code { 'TheLib' }
    library { 'The Library' }
    location_code { 'chemperi' }
    location { 'ChemLib' }
    sequence(:holding_id) { |n| "67890#{n}" }

    skip_create
    initialize_with { new(**attributes) }
  end
end
