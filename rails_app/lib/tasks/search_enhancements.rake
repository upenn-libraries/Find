# frozen_string_literal: true
#
namespace :search_enhancements do
  desc 'Generate sample Subjects'
  task generate_sample_subjects: :environment do
    conn = SolrTools.connection

    response = conn.get('/solr/find-development/select') do |req|
      req.params['q'] = '*:*'
      req.params['json.facet'] = {
        categories: {
          type: 'terms',
          field: 'subject_facet',
          limit: -1
        }
      }.to_json
    end

    parsed_response = JSON.parse(response.body)

    facets = parsed_response['facets']['categories']['buckets'].map { |facet| facet['val'] }
    service = Embeddings::Service.new(input: facets)

    puts 'Requesting subject embeddings from LLM'
    service.embeddings

    puts 'Storing subjects in database'
    service.commit
  end
end
