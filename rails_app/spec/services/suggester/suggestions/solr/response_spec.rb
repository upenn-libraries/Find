# frozen_string_literal: true

describe Suggester::Suggestions::Solr::Response do
  include Suggester::SpecHelpers

  let(:fixture_name) { 'response' }
  let(:parsed_body) { JSON.parse json_fixture(fixture_name, 'suggester/solr') }
  let(:response) { described_class.new(body: parsed_body, query: 'art') }

  describe '#terms' do
    it 'returns all the terms' do
      expect(response.terms).to eq ['The dental <b>art</b> : practical treatise on dental surgery',
                                    'journal of <b>art</b>']
    end

    it 'returns only terms from a specified dictionary' do
      expect(response.terms(dictionary: 'title')).to eq ['The dental <b>art</b> : practical treatise on dental surgery']
    end
  end

  describe '#suggestions' do
    let(:fixture_name) { 'response' }
    let(:fixture_suggesters) { %i[title notable_title] }

    it 'returns the hash containing expected suggester keys' do
      expect(response.suggestions.keys).to eq fixture_suggesters
    end

    it 'returns an array of the suggestion data provided by each suggester' do
      fixture_suggesters.each do |suggester|
        expect(response.suggestions[suggester].first.keys).to contain_exactly('payload', 'term', 'weight')
      end
    end
  end
end
