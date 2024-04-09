# frozen_string_literal: true

FactoryBot.define do
  # attributes for Illiad Api version 1
  # use `add_attribute` to alleviate some of the ugliness when defining PascalCase fields using the shorthand. This is
  # equivalent to the shorthand method to define attributes used in other factories.
  factory :illiad_api_error_response, class: Hash do
    add_attribute(:Message) { 'The request is invalid.' }

    trait :with_model_error do
      add_attribute(:ModelState) { { model: ['An error has occurred.'] } }
    end

    skip_create
    initialize_with { attributes.deep_stringify_keys }
  end
end
