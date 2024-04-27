# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'Inventory::Service::Item' do
    item do
      {
        'bib_data' => {},
        'holding_data' => {},
        'item_data' => {}
      }
    end

    initialize_with { new(item) }
  end

  trait :aeon_requestable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'scyarn' }
      item
    end
  end

  trait :at_archives do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'Library' }
      item['item_data']['library'] = { 'desc' => 'University Archives' }
      item
    end
  end

  trait :checkoutable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '1' }
      item['item_data']['location'] = { 'value' => 'Library' }
      item
    end
  end

  trait :scannable do
    item do
      item = attributes_for(:item, :checkoutable)[:item]
      item['item_data']['physical_material_type'] = { 'value' => 'book' }
      item
    end
  end
end
