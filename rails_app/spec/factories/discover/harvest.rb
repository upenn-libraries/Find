# frozen_string_literal: true

FactoryBot.define do
  factory :harvest, class: 'Discover::Harvest' do
    source { 'penn_museum' }
    resource_last_modified { '2026-02-11 14:31:08.000000000 -0500' }
    etag { '"89f5383-64a9169f665d2"' }
  end
end
