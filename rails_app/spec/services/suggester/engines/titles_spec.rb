# frozen_string_literal: true

describe Suggester::Engines::Titles do
  include Suggester::SpecHelpers
  include_context 'with cleared engine registry'

  let(:query) { 'art' }
  let(:engine) { described_class.new(query: query, context: {}) }

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

    before do
      stub_solr_suggestions_request(query_params: { "suggest.q": query },
                                    response_body: json_fixture('response', 'suggester/solr'))
    end

    it 'returns a Suggestions instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'returns expected entries' do
      expect(actions.entries.first).to have_attributes(
        label: 'The Journal of Art (online)', url: '/catalog/9977045594503681'
      )
    end
  end

  describe '#completions' do
    context 'with a single dictionary response' do
      before do
        stub_solr_suggestions_request(query_params: { "suggest.q": query },
                                      response_body: json_fixture('response', 'suggester/solr'))
      end

      it 'returns a Suggestions instance' do
        expect(engine.completions).to be_a(Suggester::Suggestions::Suggestion)
      end

      it 'contains expected entries' do
        expect(engine.completions.entries).to eq ['The dental <b>art</b> : practical treatise on dental surgery']
      end
    end
  end
end
