# frozen_string_literal: true

FactoryBot.define do
  factory :alert do
    scope { 'alert' }
    on { true }
    text { '<p>text text</p>' }
  end
end
