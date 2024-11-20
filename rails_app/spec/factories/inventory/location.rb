# frozen_string_literal: true

FactoryBot.define do
  factory :location, class: 'Inventory::Location' do
    location_code { 'vanp' }
    location_name { 'Van Pelt Library' }
    library_code  { 'VanPeltLib' }
    library_name  { 'Van Pelt Library' }

    trait :aeon do
      library_code  { 'KatzLib' }
      location_code { 'cjsambx' }
    end

    trait :aeon_onsite do
      library_code { 'KatzLib' }
      location_code { 'cjsambx' }
    end

    trait :aeon_offsite do
      library_code { Settings.fulfillment.restricted_libraries.libra }
      location_code { 'athstor' }
    end

    trait :archives do
      library_code { Settings.fulfillment.restricted_libraries.archives }
      location_code { 'univarch' }
    end

    trait :hsp do
      library_code { Settings.fulfillment.restricted_libraries.hsp }
    end

    trait :libra do
      library_code { Settings.fulfillment.restricted_libraries.libra }
      location_code { 'stor' }
    end

    skip_create
    initialize_with { new(**attributes) }
  end
end
