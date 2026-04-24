# frozen_string_literal: true

describe Suggester::Engines::InternalIdentifier do
  include_context 'with cleared engine registry'
  let(:query) { '9977568423203681' }
  let(:engine) { described_class.new(query: query, context: {}) }

  describe '.actions_weight' do
    it 'returns expected base actions weight' do
      expect(described_class.actions_weight).to eq described_class::BASE_ACTIONS_WEIGHT
    end
  end

  describe '.completions_weight' do
    it 'returns expected base completions weight' do
      expect(described_class.completions_weight).to eq described_class::BASE_COMPLETIONS_WEIGHT
    end
  end

  describe '.suggest?' do
    context 'with a query including an mms id' do
      it 'returns true' do
        expect(described_class.suggest?(query)).to be true
      end
    end

    context 'without a query including an mms id' do
      it 'returns false' do
        expect(described_class.suggest?('997756abcd8423203681')).to be false
      end
    end
  end

  describe '#actions' do
    let(:actions) { engine.actions }

    it 'returns a Suggestions instance' do
      expect(actions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains expected entries' do
      expect(actions.entries).to contain_exactly(
        an_object_having_attributes(label: "View record <b>#{engine.mms_id}</b>",
                                    url: "/catalog/#{engine.mms_id}")
      )
    end
  end

  describe '#completions' do
    let(:completions) { engine.completions }

    it 'returns a Suggestions instance' do
      expect(completions).to be_a(Suggester::Suggestions::Suggestion)
    end

    it 'contains no entries' do
      expect(completions).to have_attributes(entries: [])
    end
  end
end
