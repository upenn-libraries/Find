# frozen_string_literal: true

# Named entity recognition
module NER
  # extract persons from user query
  class Service
    class << self
      def extract_persons(query)
        return [] if query.blank?

        begin
          uri = URI('http://localhost:5001/ner')
          response = Faraday.post(uri, { text: query }.to_json, 'Content-Type' => 'application/json')
          person_entities = JSON.parse(response.body).filter_map { |e| e if e['label'] == 'PERSON' }
          person_entities.filter_map { |p| p['text'] }
        rescue StandardError => e
          warn "NER service failed: #{e.message}"
          []
        end
      end
    end
  end
end
