# frozen_string_literal: true

FactoryBot.define do
  factory :alma_bib_set, class: 'Alma::BibSet' do
    bib do
      {
        'title' => 'Test Book',
        'author' => 'Test Author',
        'date_of_publication' => '1999'
      }
    end

    skip_create
    initialize_with { Alma::BibSet.new({ 'bib' => [attributes[:bib]] }) }
  end
end
