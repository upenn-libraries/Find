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
          'policy' => { 'value' => 'book/seria', 'desc' => 'Book/serial' },
          'description' => "MS #{Faker::Number.number(digits: 4)}",
          'location' => { 'value' => 'thelocation', 'desc' => 'The Location' },
          'library' => { 'value' => 'thelibrary', 'desc' => 'The Library' },
          'pid' => Faker::Number.number(digits: 10),
          'physical_material_type' => { 'value' => 'BOOK', 'desc' => 'Book' }
        }
      }
    end

    # request_options_list is lazy-loaded in this class, and has no setter method, so we need a transient
    # attribute and corresponding after-build hook to be able to include this in our factory.
    transient do
      request_options_list { [Fulfillment::Endpoint::Alma::HOLD_TYPE] }
    end

    skip_create
    initialize_with do
      new(Alma::BibItem.new(item))
    end

    after(:build) do |item, evaluator|
      item.instance_variable_set :@request_options_list, evaluator.request_options_list
    end
  end

  trait :not_in_place do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '0' }
      item
    end
  end

  trait :in_temp_location do
    item do
      item = attributes_for(:item)[:item]
      item['holding_data'] = { 'in_temp_location' => true }
      item['holding_data']['temp_library'] = { 'value' => 'templib' }
      item['holding_data']['temp_location'] = { 'value' => 'temploc' }
      item['holding_data']['temp_policy'] = { 'value' => 'reserves' }
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

  # Policy Traits
  trait :not_loanable do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['due_date_policy'] = Settings.fulfillment.due_date_policy.not_loanable
      item
    end
  end

  trait :on_reserve do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => Settings.fulfillment.policies.reserve }
      item
    end
  end

  trait :non_circ do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => Settings.fulfillment.policies.non_circ }
      item
    end
  end

  trait :at_reference do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['policy'] = { 'value' => Settings.fulfillment.policies.reference }
      item
    end
  end

  # Material type traits
  trait :laptop_material_type do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['physical_material_type'] = { 'value' => 'LPTOP', 'desc' => 'Laptop' }
      item
    end
  end

  # Location traits
  trait :aeon_location do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'scyarn' }
      item
    end
  end

  trait :not_aeon_location do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'notaeon' }
      item
    end
  end

  trait :at_hsp do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['library'] = { 'value' => Settings.fulfillment.restricted_libraries.hsp }
      item
    end
  end

  trait :at_archives do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['location'] = { 'value' => 'univarch' }
      item['item_data']['library'] = { 'value' => Settings.fulfillment.restricted_libraries.archives }
      item
    end
  end

  # Combined traits
  # @todo it would be nice to make all these traits 'stackable'/able to be combined. as of now the attributes_for() call
  #       means the last included trait overrides previously applied traits.
  trait :laptop_material_type_not_in_place do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '0' }
      item['item_data']['physical_material_type'] = { 'value' => 'LPTOP', 'desc' => 'Laptop' }
      item
    end
  end

  trait :not_loanable_not_in_place do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['due_date_policy'] = Settings.fulfillment.due_date_policy.not_loanable
      item['item_data']['base_status'] = { 'value' => '0' }
      item
    end
  end

  trait :not_in_place_non_circulating do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '0' }
      item['item_data']['policy'] = { 'value' => Settings.fulfillment.policies.non_circ }
      item
    end
  end

  trait :in_place_with_restricted_short_loan_policy do
    item do
      item = attributes_for(:item)[:item]
      item['item_data']['base_status'] = { 'value' => '1' }
      item['item_data']['policy'] = { 'value' => '3 Day loan' }
      item
    end
    request_options_list { [] }
  end
end
