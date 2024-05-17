# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'Inventory::Service::Item' do
    item do
      {
        'bib_data' => {
          'title' => Faker::Book.title
        },
        'holding_data' => {},
        'item_data' => {
          'base_status' => { 'value' => '1' },
          'description' => "MS #{Faker::Number.number(digits: 4)}",
          'location' => { 'value' => 'library' },
          'library' => { 'desc' => 'The Library' },
          'pid' => Faker::Number.number(digits: 10),
          'physical_material_type' => { 'desc' => 'Book' }
        }
      }
    end

    skip_create
    initialize_with { new(item) }
  end

  trait :checkoutable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '1' }
      item['item_data']['location'] = { 'value' => 'Library' }
      item
    end
  end

  trait :not_checkoutable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '0' }
      item['item_data']['due_date_policy'] = 'Not loanable'
      item
    end
  end

  trait :aeon_requestable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'scyarn' }
      item
    end
  end

  trait :not_scannable do
    item do
      item = attributes_for(:item, :checkoutable)[:item]
      item['item_data']['physical_material_type'] = { 'value' => 'RECORD' }
      item
    end
  end

  trait :at_hsp do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['library'] = { 'value' => Inventory::Constants::HSP_LIBRARY }
      item
    end
  end

  trait :at_reference do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => 'reference' }
      item
    end
  end

  trait :on_reserve do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => 'reserve' }
      item
    end
  end

  trait :at_archives do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'univarch' }
      item['item_data']['library'] = { 'value' => Inventory::Constants::ARCHIVES_LIBRARY }
      item
    end
  end

  trait :in_house_use_only do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => Inventory::Service::Item::IN_HOUSE_POLICY_CODE }
      item
    end
  end
end
