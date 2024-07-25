# frozen_string_literal: true

FactoryBot.define do
  factory :ils_hold, class: 'Shelf::Entry::IlsHold' do
    data { attributes_for(:alma_hold) }

    trait :resource_sharing do
      data { attributes_for(:alma_hold, :resource_sharing) }
    end

    trait :borrow_direct do
      data { attributes_for(:alma_hold, :borrow_direct) }
    end

    trait :boundwith do
      data { attributes_for(:alma_hold, :boundwith) }
    end

    skip_create
    initialize_with { Shelf::Entry::IlsHold.new(data.deep_stringify_keys) }
  end
end
