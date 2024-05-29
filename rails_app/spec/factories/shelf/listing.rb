# frozen_string_literal: true

FactoryBot.define do
  factory :shelf_listing, class: 'Shelf::Listing' do
    entries do
      [create(:ils_loan), create(:ils_hold), create(:ill_transaction)]
    end

    skip_create
    initialize_with { Shelf::Listing.new(entries) }
  end
end
