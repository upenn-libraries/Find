# frozen_string_literal: true

describe Suggester::Suggestions::Solr::Response do
  include Suggester::SpecHelpers
  let(:parsed_body) { JSON.parse json_fixture('response', 'suggester/solr') }
  let(:response) { described_class.new(body: parsed_body, query: 'art') }

  describe '#terms' do
    it 'returns all the terms' do
      expect(response.terms).to eq [
        'The dental <b>art</b> : practical treatise on dental surgery',
        'Museum inventories of Delaware <b>art</b>ifacts : discussions of the'\
          ' Indian <b>art</b>ifacts found in the State of Delaware and owned by...',
        'An inquiry into the fine <b>art</b>s',
        'Falasṭin(ah) : omanut nashim mi-Falasṭin = Filasṭīn(ah) : fann al-marʼah min'\
          ' Filasṭīn = Palestin(a) : women\'s <b>art</b> form Palestine',
        'At the crossroads of Asia and Europe : 20th century masterpieces from the A.'\
          ' Kasteyev State Museum of <b>Art</b>s in...'
      ]
    end

      context 'with multiple suggesters' do
        let(:parsed_body) { JSON.parse json_fixture('response_with_multiple_suggesters', 'suggester/solr') }

        it 'returns all terms' do
          expect(response.terms).to eq ["The dental <b>art</b> : practical treatise on dental surgery",
                                        "<b>Art</b>uro Alfonso Schomburg"]
        end
    end
  end

  describe '#suggestions' do
    it 'returns the hash containing solr suggestions payload' do
      expect(response.suggestions).to eq(
        { 'title' => [{ 'term' => 'The dental <b>art</b> : practical treatise on dental surgery',
                        'payload' => '9977323252003681', 'weight' => 16 },

                      { 'term' => 'Museum inventories of Delaware <b>art</b>ifacts : discussions of the'\
                        ' Indian <b>art</b>ifacts found in the State of Delaware and owned by...',
                        'payload' => '9934303363503681', 'weight' => 12 },

                      { 'payload' => '9920306233503681', 'term' => 'An inquiry into the fine <b>art</b>s',
                        'weight' => 9 },

                      { 'payload' => '9978884923903681', 'term' => 'Falasṭin(ah) : omanut nashim mi-Falasṭin = '\
                        'Filasṭīn(ah) : fann al-marʼah min Filasṭīn = Palestin(a) : women\'s <b>art</b> form Palestine',
                        'weight' => -7 },

                      { 'payload' => '9979083013503681', 'term' => 'At the crossroads of Asia and Europe : 20th '\
                      'century masterpieces from the A. Kasteyev State Museum of <b>Art</b>s in...',
                        'weight' => -20 }] }
      )
    end

    context 'with multiple suggesters' do
      let(:parsed_body) { JSON.parse json_fixture('response_with_multiple_suggesters', 'suggester/solr') }

      it 'returns the suggestions from each suggester' do
        expect(response.suggestions).to eq(
          { 'author' => [{ 'payload' => '', 'term' => '<b>Art</b>uro Alfonso Schomburg', 'weight' => 20 }],

            'title' => [{ 'payload' => '9977323252003681',
                          'term' => 'The dental <b>art</b> : practical treatise on dental surgery',
                          'weight' => 20 }] }
        )
      end
    end
  end
end
