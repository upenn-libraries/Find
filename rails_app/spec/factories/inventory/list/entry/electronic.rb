# frozen_string_literal: true

FactoryBot.define do
  factory :electronic_entry, class: 'Inventory::List::Entry::Electronic' do
    mms_id { '1234567890' }
    activation_status { Inventory::Constants::ELEC_AVAILABLE }
    coverage_statement { 'Available from 01/06/2000 until 12/23/2021.' }
    public_note { 'Note: Use this link for Penn-sponsored access.' }
    portfolio_pid { '12345' }
    collection { 'Gale Academic OneFile' }
    collection_id { nil }

    # If collection and collection_id are not explicitly passed in, factorybot thinks they are an association
    # and ignores them. https://github.com/thoughtbot/factory_bot/issues/1142
    skip_create
    initialize_with { new(collection: collection, collection_id: collection_id, **attributes) }

    trait :without_collection do
      collection { '' }
    end
  end
end
