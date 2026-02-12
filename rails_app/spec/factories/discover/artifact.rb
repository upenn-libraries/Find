# frozen_string_literal: true

FactoryBot.define do
  factory :artifact, class: 'Discover::Artifact' do
    title { 'Statue Fragment' }
    link {  'https://penn.museum/collections/object/420280' }
    thumbnail_url { 'placeholder.com' }
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
