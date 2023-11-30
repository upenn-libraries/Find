# frozen_string_literal: true

shared_examples_for 'LazyMARCParsing' do
  let(:object) { described_class.new(source_hash) }
  let(:source_hash) do
    { id: ['1234567891234567'], marcxml_marcxml: ['<record></record>'] }
  end
  let(:parser) { instance_double PennMARC::Parser }

  context 'with calls to PennMARC' do
    before do
      allow(parser).to respond_to(:title_show).and_return 'A Title'
    end

    it 'delegates calls to parser' do
      expect(object.marc(:title_show)).to eq 'A Title'
    end
  end
end
