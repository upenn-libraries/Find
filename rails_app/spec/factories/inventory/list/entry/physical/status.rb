# frozen_string_literal: true

FactoryBot.define do
  factory :physical_entry_status, class: 'Inventory::List::Entry::Physical::Status' do
    status { Inventory::Constants::AVAILABLE }
    location { create :location }

    trait :check_holdings do
      status { Inventory::Constants::CHECK_HOLDINGS }
    end

    trait :unavailable do
      status { Inventory::Constants::UNAVAILABLE }
    end

    trait :aeon_onsite do
      location { create :location, :aeon_onsite }
    end

    trait :aeon_offsite do
      location { create :location, :aeon_offsite }
    end

    trait :offsite do
      location { create :location, :libra }
    end

    trait :unrequestable do
      location { create :location, :hsp }
    end

    skip_create
    initialize_with { new(**attributes) }
  end
end
