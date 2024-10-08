# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'Inventory::Item' do
    item do
      {
        'bib_data' => {
          'title' => Faker::Book.title,
          'author' => Faker::Book.author
        },
        'holding_data' => { 'holding_id' => '456' },
        'item_data' => {
          'base_status' => { 'value' => '1' },
          'description' => "MS #{Faker::Number.number(digits: 4)}",
          'location' => { 'value' => 'thelocation', 'desc' => 'The Location' },
          'library' => { 'value' => 'thelibrary', 'desc' => 'The Library' },
          'pid' => Faker::Number.number(digits: 10),
          'physical_material_type' => { 'desc' => 'Book' }
        }
      }
    end

    skip_create
    initialize_with do
      new(Alma::BibItem.new(item))
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

  trait :not_aeon_requestable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'notaeon' }
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
      item['item_data']['library'] = { 'value' => Inventory::Location::HSP }
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
      item['item_data']['library'] = { 'value' => Inventory::Location::ARCHIVES }
      item
    end
  end

  trait :in_house_use_only do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => Inventory::Item::IN_HOUSE_POLICY_CODE }
      item
    end
  end

  trait :in_temp_location do
    item do
      item = attributes_for(:item)[:item]
      item['holding_data'] = { 'in_temp_location' => true }
      item['holding_data']['temp_library'] = { 'value' => 'templib' }
      item['holding_data']['temp_location'] = { 'value' => 'temploc' }
      item['holding_data']['temp_call_number'] = 'tempcall'
      item
    end
  end

  trait :boundwith do
    item do
      item = attributes_for(:item)[:item]
      item['boundwith'] = 'true'
      item
    end
  end

  trait :without_item do
    item do
      item = attributes_for(:item)[:item]
      item['item_data'] = {}
      item['holding_data']['location'] = { 'value' => 'vanp', 'desc' => 'Van Pelt Library' }
      item['holding_data']['library'] = { 'value' => 'ValPeltLib', 'desc' => 'Van Pelt Library' }
      item
    end
  end
end
