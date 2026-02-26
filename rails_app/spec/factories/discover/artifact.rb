# frozen_string_literal: true

FactoryBot.define do
  factory :artifact, class: 'Discover::Artifact' do
    sequence(:artifact_identifier) { |n| "ABCD-#{n}" }

    identifier { generate(:artifact_identifier) }
    title { 'Statue Fragment' }
    link {  "https://penn.museum/collections/object/#{identifier}" }
    thumbnail { '1234_300.jpg' }
    location { 'American' }
    format { 'Volcanic Stone' }
    creator { '' }
    description do
      'Fragmentary head of statue  Face has large eyes, protruding' \
      'nose, and open mouth with two teeth bared,  Side and back' \
      'of head are carved, top of head flat and unworked.  '\
      'Represents the Fire God (Huehueteotl).'
    end
    on_display { true }
  end
end
