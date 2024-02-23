# frozen_string_literal: true

describe Find::LinkToProcessor do
  let(:config) { Blacklight::Configuration::Field.new(key: 'field') }
  let(:processor) do
    described_class.new(values, config, SolrDocument.new, {},
                        { context: 'show' }, [Blacklight::Rendering::Terminator])
  end

  context 'with one link hash' do
    let(:values) { [{ link_text: 'Link', link_url: 'https://test.com/' }] }

    it 'renders a single link tag' do
      expect(processor.render).to contain_exactly '<a href="https://test.com/">Link</a>'
    end
  end

  context 'with multiple link hashes' do
    let(:values) do
      [{ link_text: 'Link', link_url: 'https://test.com/' },
       { link_text: 'Another Link', link_url: 'https://another-test.com/' }]
    end

    it 'renders multiple link tags' do
      expect(processor.render).to contain_exactly '<a href="https://test.com/">Link</a>',
                                                  '<a href="https://another-test.com/">Another Link</a>'
    end
  end
end
