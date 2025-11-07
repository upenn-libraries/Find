# frozen_string_literal: true

describe Suggester::Engines::TitleCompletion do
  include Suggester::SpecHelpers
  include_context 'with cleared engine registry'

  let(:engine) { described_class.new(query: 'query', context: {}) }

  describe '.weight' do
    it 'returns expected base weight' do
      expect(described_class.weight).to eq described_class::BASE_WEIGHT
    end
  end

  describe '.suggest?' do
    let(:minimum_chars_required) { described_class::MINIMUM_CHARS_REQUIRED }

    context 'when the query length is equal to the minimum required characters' do
      it 'returns true' do
        expect(described_class.suggest?('a' * minimum_chars_required)).to be true
      end
    end

    context 'when the query length is greater than the minimum required characters' do
      it 'returns true' do
        expect(described_class.suggest?('a' * (minimum_chars_required + 1))).to be true
      end
    end

    context 'when the query length is less than the minimum required characters' do
      it 'returns false' do
        expect(described_class.suggest?('a' * (minimum_chars_required - 1))).to be false
      end
    end
  end

  describe '#actions' do
    let(:actions) { engine.actions }

    it 'returns a Suggestions instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains no entries' do
      expect(actions).to have_attributes(entries: [])
    end
  end

  describe '#completions' do
    let(:query) { 'art' }
    let(:engine) { described_class.new(query: query, context: {}) }

    before do
      stub_solr_suggestions_request(query_params: { "suggest.q": query },
                                    response_body: json_fixture('response', 'suggester/solr'))
    end

    it 'returns a Suggestions instance' do
      expect(engine.completions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains expected entries' do
      expect(engine.completions).to have_attributes(
        entries: [
          'The dental <b>art</b> : practical treatise on dental surgery',
          'Museum inventories of Delaware <b>art</b>ifacts : discussions of the'\
            ' Indian <b>art</b>ifacts found in the State of Delaware and owned by...',
          'An inquiry into the fine <b>art</b>s',
          'Falasṭin(ah) : omanut nashim mi-Falasṭin = Filasṭīn(ah) : fann al-marʼah min'\
          ' Filasṭīn = Palestin(a) : women\'s <b>art</b> form Palestine',
          'At the crossroads of Asia and Europe : 20th century masterpieces from the A.'\
            ' Kasteyev State Museum of <b>Art</b>s in...'
        ]
      )
    end
  end
end
