# frozen_string_literal: true

FactoryBot.define do
  factory :shelf_listing, class: 'Shelf::Listing' do
    entries do
      [create(:ils_loan), create(:ils_hold), create(:ill_transaction)]
    end

    filters { Shelf::Service::FILTERS }
    sort { Shelf::Service::LAST_UPDATED_BY }
    order { Shelf::Service::DESCENDING }

    skip_create
    initialize_with { Shelf::Listing.new(entries, filters: filters, sort: sort, order: order) }
  end
end
