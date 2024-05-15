# frozen_string_literal: true

FactoryBot.define do
  factory :ils_hold, class: 'Shelf::Entry::IlsHold' do
    data { attributes_for(:alma_hold) }

    trait :borrow_direct do
      data { attributes_for(:alma_hold, :borrow_direct) }
    end

    skip_create
    initialize_with { Shelf::Entry::IlsHold.new(data.deep_stringify_keys) }
  end
end
