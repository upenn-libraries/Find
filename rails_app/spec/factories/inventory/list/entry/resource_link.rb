# frozen_string_literal: true

FactoryBot.define do
  factory :resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    href { 'http://hdl.library.upenn.edu/1017/126017' }
    description { 'Connect to resource' }

    skip_create
    initialize_with { new(**attributes) }
  end

  factory :colenda_resource_link_entry, class: 'Inventory::List::Entry::ResourceLink' do
    id { 1 }
    href { 'https://colenda.library.upenn.edu/catalog/81431-p3pr7n97q' }
    description { 'Digital facsimile for browsing Part 1: folders 1-10 (Colenda)' }

    skip_create
    initialize_with { new(**attributes) }
  end
end
