# frozen_string_literal: true

describe Find::JoinProcessor do
  let(:config) { Blacklight::Configuration::Field.new(key: 'field') }
  let(:context) { {} }
  let(:processor) do
    described_class.new(values, config, SolrDocument.new, context,
                        { context: 'show' }, [Blacklight::Rendering::Terminator])
  end

  context 'with one value' do
    let(:values) { ['single value'] }

    it 'does not convert it into a list' do
      expect(processor.render).to eq('single value')
    end
  end

  context 'with multiple values' do
    let(:values) { ['Chapter 1', 'Chapter 2'] }

    it 'concatenates values into an unordered list' do
      expect(processor.render).to eq('<ul><li>Chapter 1</li><li>Chapter 2</li></ul>')
    end
  end

  context 'with a JSON request' do
    let(:values) { ['Chapter 1', 'Chapter 2'] }
    let(:context) { Blacklight::SearchContext.new() } # TODO:

    it 'returns an array of untransformed values' do
      expect(processor.render).to eq values
    end
  end
end
