# frozen_string_literal: true

describe Find::JoinProcessor do
  let(:config) { Blacklight::Configuration::Field.new(key: 'field') }
  let(:processor) do
    described_class.new(values, config, SolrDocument.new, {},
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

  context 'with a link value' do
    let(:values) { ['<a href="https://test.com/">Test</a>'] }

    it 'displays link' do
      expect(processor.render).to eq('<a href="https://test.com/">Test</a>')
    end
  end

  context 'with multiple link values' do
    let(:values) do
      ['<a href="https://test.com/">Test</a>',
       '<a href="https://test-again.com/">Test Again</a>']
    end

    it 'displays escaped links in unordered list' do
      expect(processor.render).to eq('<ul><li>&lt;a href=&quot;https://test.com/&quot;&gt;Test&lt;/a&gt;</li>' \
                                       '<li>&lt;a href=&quot;https://test-again.com/&quot;&gt;Test Again&lt;/a&gt;' \
                                       '</li></ul>')
    end
  end
end
