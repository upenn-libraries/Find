# frozen_string_literal: true

FactoryBot.define do
  factory :ecollection_entry, class: 'Inventory::List::Entry::Ecollection' do
    mms_id { '1234567890' }
    id { '6789012345' }
    public_name { 'Barclays Capital Live' }
    public_name_override { '' }
    url { 'https://www.library.upenn.edu/lippincott' }
    public_note { '' }
    authentication_note { '' }
    portfolios { { value: 0 } }

    skip_create
    initialize_with { new(**attributes) }
  end
end
