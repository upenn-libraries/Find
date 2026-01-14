# frozen_string_literal: true

FactoryBot.define do
  factory :alma_bib_set, class: 'Alma::BibSet' do
    bib do
      {
        'title' => Faker::Book.title,
        'author' => Faker::Book.author,
        'date_of_publication' => Faker::Date.between(from: 1956, to: 2020).to_s
      }
    end

    skip_create
    initialize_with { Alma::BibSet.new({ 'bib' => [attributes[:bib]] }) }
  end
end
