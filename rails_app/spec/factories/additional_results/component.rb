# frozen_string_literal: true

FactoryBot.define do
  factory :additional_results_component, class: 'AdditionalResults::AdditionalResultsComponent' do
    transient do
      query { 'nature' }
      excluded_sources { nil }
      sources { %w[summon other_source another_source] }
      classes { '' }
    end

    skip_create

    initialize_with do
      params = { q: query }
      params[:exclude_extra] = excluded_sources if excluded_sources

      new(params: params, sources: sources, class: classes)
    end

    trait :without_query do
      query { nil }
    end

    trait :with_all_sources_generally_excluded do
      excluded_sources { 'all' }
    end

    trait :with_all_sources_explicitly_excluded do
      excluded_sources { 'summon,other_source,another_source' }
    end

    trait :with_some_sources_excluded do
      excluded_sources { 'another_source' }
    end
  end
end
