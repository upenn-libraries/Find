# frozen_string_literal: true

shared_examples_for 'LazyMARCParsing' do
  let(:object) { described_class.new(source_hash) }
  let(:source_hash) { { id: ['1234567891234567'], marcxml_marcxml: '<record></record>' } }
  let(:parser) { instance_double PennMARC::Parser }

  before do
    allow(object).to receive(:pennmarc).and_return parser
  end

  context 'with valid calls to PennMARC' do
    before do
      allow(parser).to receive(:respond_to?).with(:title_show).and_return true
    end

    context 'with no options' do
      before do
        allow(parser).to receive(:method_missing).with(:title_show, kind_of(MARC::Record)).and_return 'A Title'
      end

      it 'delegates calls to parser' do
        expect(object.marc(:title_show)).to eq 'A Title'
      end
    end

    context 'with options' do
      before do
        allow(parser).to(
          receive(:method_missing).with(:title_show, kind_of(MARC::Record), anything).and_return('A Title')
        )
      end

      it 'passes along options to the specified PennMARC method' do
        expect(object.marc(:title_show, some_option: false)).to eq 'A Title'
        expect(parser).to have_received(:method_missing).with(:title_show, kind_of(MARC::Record), some_option: false)
      end
    end
  end

  context 'with invalid call to PennMARC' do
    before do
      allow(parser).to receive(:respond_to?).with(:bogus_field).and_return false
    end

    it 'provides a helpful exception message if provided with a field PennMARC does not support' do
      expect { object.marc(:bogus_field) }.to raise_exception NameError, /bogus_field/
    end
  end
end
