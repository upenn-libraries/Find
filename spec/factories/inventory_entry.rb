# frozen_string_literal: true

FactoryBot.define do
  factory :electronic_entry, class: 'Inventory::Entry::Electronic' do
    mms_id { '1234567890' }
    activation_status { Inventory::Constants::ELEC_AVAILABLE }
    coverage_statement { 'Available from 01/06/2000 until 12/23/2021.' }
    portfolio_pid { '12345' }
    collection { 'Gale Academic OneFile' }
    collection_id { nil }

    # If collection and collection_id are not explicitly passed in, factorybot thinks they are an association
    # and ignores them. https://github.com/thoughtbot/factory_bot/issues/1142
    skip_create
    initialize_with { new(collection: collection, collection_id: collection_id, **attributes) }
  end

  factory :physical_entry, class: 'Inventory::Entry::Physical' do
    mms_id { '1234567890' }
    availability { Inventory::Constants::AVAILABLE }
    call_number { 'QD1 .C48' }
    holding_info { '1965-1971' }
    location_code { 'chemperi' }
    holding_id { '67890' }

    skip_create
    initialize_with { new(**attributes) }
  end

  factory :resource_link_entry, class: 'Inventory::Entry::ResourceLink' do
    id { 1 }
    href { 'http://hdl.library.upenn.edu/1017/126017' }
    description { 'Connect to resource' }

    skip_create
    initialize_with { new(**attributes) }
  end
end
