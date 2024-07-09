# frozen_string_literal: true

FactoryBot.define do
  factory :resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    href { 'http://hdl.library.upenn.edu/1017/126017' }
    description { 'Connect to resource' }

    skip_create
    initialize_with { new(**attributes) }
  end
end
