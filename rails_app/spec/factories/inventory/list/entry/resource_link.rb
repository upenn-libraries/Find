# frozen_string_literal: true

FactoryBot.define do
  factory :resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    link_url { 'http://hdl.library.upenn.edu/1017/126017' }
    link_text { 'Connect to resource' }

    skip_create
    initialize_with { new(**attributes) }
  end

  factory :colenda_resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    link_url { 'https://colenda.library.upenn.edu/catalog/81431-p3pr7n97q' }
    link_text { 'Digital facsimile for browsing Part 1: folders 1-10 (Colenda)' }

    skip_create
    initialize_with { new(**attributes) }
  end

  factory :digital_collections_resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    link_url { 'https://digitalcollections.library.upenn.edu/items/b1fefb14-d4b6-4ced-8cff-9bf8d8317dd1' }
    link_text { 'Full Resource' }

    skip_create
    initialize_with { new(**attributes) }
  end
end
