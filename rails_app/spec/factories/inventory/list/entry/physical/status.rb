# frozen_string_literal: true

FactoryBot.define do
  factory :physical_entry_status, class: 'Inventory::List::Entry::Physical::Status' do
    status { Inventory::Constants::AVAILABLE }
    library_code { 'vanpelt' }
    location_code { 'vanp' }

    trait :check_holdings do
      status { Inventory::Constants::CHECK_HOLDINGS }
    end

    trait :unavailable do
      status { Inventory::Constants::UNAVAILABLE }
    end

    trait :aeon_onsite do
      library_code { 'KatzLib' }
      location_code { 'cjsambx' }
    end

    trait :aeon_offsite do
      library_code { Inventory::Constants::LIBRA_LIBRARY }
      location_code { 'athstor' }
    end

    trait :offsite do
      library_code { Inventory::Constants::LIBRA_LIBRARY }
      location_code { 'stor' }
    end

    trait :unrequestable do
      library_code { Inventory::Constants::HSP_LIBRARY }
      location_code { 'hspclosed' }
    end

    skip_create
    initialize_with { new(**attributes) }
  end
end
