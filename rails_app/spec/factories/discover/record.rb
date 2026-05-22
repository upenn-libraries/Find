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
    thumbnail { nil }

    trait :from_museum do
      title { ['Title1,Title2'] }
      body do
        { creator: ['Record Creator'],
          format: ['Record Format,Record Format,Record Format'],
          location: ['Record Location'],
          publication: ['Record Publication Place', 'Record Publication Date'],
          description: ['Record Description'] }
      end
    end

    trait :with_thumbnail do
      thumbnail { 'https://www.file.com/thumbnail.jpg' }
    end

    skip_create
    initialize_with { new(**attributes) }
  end
end
