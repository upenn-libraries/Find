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

  trait :checkoutable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '1' }
      item['item_data']['location'] = { 'value' => 'Library' }
      item
    end
  end

  trait :with_bib_data do
    item do
      item = attributes_for(:item)[:item]
      item['bib_data'] = { 'title' => 'The Title' }
      item
    end
  end

  trait :with_item_data do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['pid'] = '123456789'
      item['item_data']['description'] = 'MS 1234'
      item['item_data']['physical_material_type'] = { 'desc' => 'Book' }
      item
    end
  end

  trait :with_user_due_date_policy do
    item do
      item = attributes_for(:item)[:item]
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

  trait :scannable do
    item do
      item = attributes_for(:item, :checkoutable)[:item]
      item['item_data']['physical_material_type'] = { 'value' => 'book' }
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
      item['item_data']['library'] = { 'value' => 'HSPLib' }
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
      item['item_data']['location'] = { 'value' => 'Library' }
      item['item_data']['library'] = { 'desc' => 'University Archives' }
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
