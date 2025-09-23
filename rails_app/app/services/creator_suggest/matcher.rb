# frozen_string_literal: true

# Orchestrates NER + fuzzy match against Creator
module CreatorSuggest
  class Matcher
    def call(query)
      return [] if query.to_s.strip.empty?

      persons = NER::Service.extract_persons(query.to_s)
      persons.map { |person|
        creators = Creator.search_by_name(person).to_a
        next if creators.blank?

        { person: person, creators: creators }
      }.compact
    rescue StandardError => e
      Rails.logger.warn("[CreatorSuggest::Matcher] #{e.class}: #{e.message}")
      []
    end
  end
end
