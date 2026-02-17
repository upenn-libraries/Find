# frozen_string_literal: true

FactoryBot.define do
  factory :discover_record, class: 'Discover::Record' do
    title { ['Title'] }
    body do
      { creator: ['Record Creator'],
        format: ['Record Format'],
        location: ['Record Location'],
        publication: ['Record Publication Place', 'Record Publication Date'],
        description: ['Record Description'] }
    end
    identifiers { {} }
    link_url { 'https://www.test.com/record' }
    thumbnail_url { nil }

    trait :from_museum do
      title { ['Title | Location'] }
      body do
        { creator: ['Record Creator'],
          format: ['Record Format'],
          location: [],
          publication: ['Record Publication Place', 'Record Publication Date'],
          description: ['Record Description'] }
      end
    end

    trait :with_thumbnail do
      thumbnail_url { 'https://www.file.com/thumbnail.jpg' }
    end

    skip_create
    initialize_with { new(**attributes) }
  end
end
