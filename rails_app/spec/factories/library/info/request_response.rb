# frozen_string_literal: true

FactoryBot.define do
  factory :library_info_api_request_response, class: 'Library::Info::Request' do
    sequence(:num) { |n| n }
    add_attribute(:name) { 'The Library' }
    add_attribute(:node_id) { 1234 }
    add_attribute(:lib_code) { 'TheLib' }
    add_attribute(:formal_title) { 'The Fancy Name Library' }
    add_attribute(:url) { '' }
    add_attribute(:address1) { '' }
    add_attribute(:address2) { '' }
    add_attribute(:city) { '' }
    add_attribute(:state_code) { '' }
    add_attribute(:state_name) { '' }
    add_attribute(:zip) { '' }
    add_attribute(:google_maps) { '' }
    add_attribute(:email) { '' }
    add_attribute(:phone) { '' }
    add_attribute(:todays_hours) { '' }
    add_attribute(:hours_url) { '' }
    add_attribute(:libcal_id) { '' }
    add_attribute(:thumbnail) { '' }

    trait :with_all_info do
      add_attribute(:url) { 'https://www.library.upenn.edu/lib' }
      add_attribute(:address1) { '123 Fake Street' }
      add_attribute(:address2) { 'Apt. 123' }
      add_attribute(:city) { 'Philadelphia' }
      add_attribute(:state_code) { 'PA' }
      add_attribute(:state_name) { 'Pennsylvania' }
      add_attribute(:zip) { '19104' }
      add_attribute(:google_maps) { 'https://goo.gl/maps/xYX61UxLCMiCtLYs6' }
      add_attribute(:email) { 'lib@upenn.edu' }
      add_attribute(:phone) { '215-898-5924' }
      add_attribute(:todays_hours) { '8:30am - 6pm' }
      add_attribute(:hours_url) { 'https://www.library.upenn.edu/lib/hours' }
      add_attribute(:libcal_id) { 123 }
      add_attribute(:thumbnail) { 'https://www.library.upenn.edu/sites/default/files/styles/libraries_api_thumbnail/public/2022-08/lippincott-brian.jpg?itok=20zXWmft' }
    end

    trait :without_links do
      add_attribute(:address1) { '123 Fake Street' }
      add_attribute(:address2) { 'Apt. 123' }
      add_attribute(:city) { 'Philadelphia' }
      add_attribute(:state_code) { 'PA' }
      add_attribute(:state_name) { 'Pennsylvania' }
      add_attribute(:zip) { '19104' }
      add_attribute(:email) { 'lib@upenn.edu' }
      add_attribute(:phone) { '215-898-5924' }
      add_attribute(:todays_hours) { '8:30am - 6pm' }
      add_attribute(:libcal_id) { 321 }
      add_attribute(:thumbnail) { 'https://www.library.upenn.edu/sites/default/files/styles/libraries_api_thumbnail/public/2022-08/lippincott-brian.jpg?itok=20zXWmft' }
    end

    skip_create
    initialize_with { attributes }
  end
end
