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

    it 'returns the hash containing expected suggester keys' do
      expect(response.suggestions.keys).to eq described_class::SUGGESTER_MAPPING.keys
    end

    it 'returns an array of the mapped suggestion objects for each suggester' do
      described_class::SUGGESTER_MAPPING.each_key do |suggester|
        expect(response.suggestions[suggester].first).to be_a described_class::SUGGESTER_MAPPING[suggester]
      end
    end

    it 'parses the JSON payload of the notable title suggester response' do
      expect(response.suggestions[:notable_title].first).to(have_attributes(label: 'The Journal of Art (online)',
                                                                            mmsid: '9977045594503681'))
    end

    context 'with an unsupported suggester' do
      let(:fixture_name) { 'response_including_unsupported_suggester' }

      it 'raises an exception calling out the unsupported response data' do
        expect { response.suggestions }.to raise_error(StandardError, /author/)
      end
    end

    context 'with a malformed JSON payload' do
      let(:fixture_name) { 'response_including_malformed_payload' }

      it 'ignores the problematic suggestion' do
        expect(response.suggestions[:notable_title]).to eq []
      end
    end
  end
end
