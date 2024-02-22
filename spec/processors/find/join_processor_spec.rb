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
      expect(processor.render).to eq('<ul id="field-list" class="list-unstyled">' \
                                       '<li class="">Chapter 1</li><li class="">Chapter 2</li></ul>')
    end
  end

  context 'with a link value' do
    let(:values) { [{ link_text: 'test link', link_url: 'https://www.link.com/' }] }

    it 'converts link values into styled list' do
      expect(processor.render).to eq('<ul id="field-list" class="list-unstyled list-group">' \
                                       '<li class="list-group-item">' \
                                       '<a href="https://www.link.com/">test link</a></li></ul>')
    end
  end

  context 'with multiple link values' do
    let(:values) do
      [{ link_text: 'test link', link_url: 'https://www.link.com/' },
       { link_text: 'another test link', link_url: 'https://www.another-link.com/' }]
    end

    it 'converts multiple link values into styled list' do
      expect(processor.render).to eq('<ul id="field-list" class="list-unstyled list-group">' \
                                       '<li class="list-group-item"><a href="https://www.link.com/">test link</a>' \
                                       '</li><li class="list-group-item"><a href="https://www.another-link.com/">' \
                                       'another test link</a></li></ul>')
    end
  end
end
