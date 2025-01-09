# frozen_string_literal: true

shared_examples_for 'OpenUrlExport' do
  include FixtureHelpers

  let(:source) { { marcxml_marcxml: marcxml } }
  let(:object) { described_class.new(source) }

  describe '#export_as_openurl_ctx_kev' do
    context 'with a book format' do
      let(:marcxml) { marc_xml_fixture('print_monograph') }
      let(:expected_title) { { 'rft.title' => 'The hypothalamus of the cat' } }

      it 'returns a query string containing the book title' do
        expect(object.export_as_openurl_ctx_kev('book')).to include expected_title.to_query
      end
    end

    context 'with a journal format' do
      let(:marcxml) { marc_xml_fixture('print_journal') }
      let(:expected_title) { { 'rft.title' => 'Chemical communications.' } }

      it 'returns a query string containing the journal title' do
        expect(object.export_as_openurl_ctx_kev('journal')).to include expected_title.to_query
      end
    end

    context 'with a non-book or journal format' do
      let(:marcxml) { marc_xml_fixture('special_collections_manuscript') }
      let(:expected_title) do
        { 'rft.title' => 'Sermon de nuestra Señora del Santissimo Rosario : año de 1818, poconchi.' }
      end

      it 'returns a query string containing the journal title' do
        expect(object.export_as_openurl_ctx_kev('manuscript')).to include expected_title.to_query
      end
    end
  end
end
