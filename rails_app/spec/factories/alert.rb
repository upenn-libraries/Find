# frozen_string_literal: true

FactoryBot.define do
  factory :alert do
    scope { 'alert' }
    on { false }
    text { '<p>Test Text</p>' }
  end
end
