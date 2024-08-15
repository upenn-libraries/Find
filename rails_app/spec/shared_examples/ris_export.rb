# frozen_string_literal: true

# Examples for the RIS format on the six fixtures
shared_examples_for 'RisExport' do
  include FixtureHelpers

  # Test the three RIS on the six fixtures: conference, electronic_database, electronic_journal,
  # print_journal, print_monograph, and record_with_added_date
  describe '#export_as_ris' do
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    context 'with a conference record' do
      let(:marcxml) { JSON.parse(json_fixture('conference'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq %(TY  - BOOK
TI  - Report of the Conference of FAO : nineteenth session, Rome, 12 November - 1 December 1977.
PY  - 1979\nCY  - Rome :\nPB  - The Organization,\nER  - )
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq %(TY  - GEN\nTI  - GEOBASE\nPY  - 1900\nCY  - New York :
PB  - Elsevier Science.\nER  - )
      end
    end

    context 'with an electronic journal' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq %(TY  - JOUR\nTI  - Nature.\nPY  - 1869\nCY  - [London] :
PB  - Nature Pub. Group\nER  - )
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq %(TY  - JOUR\nTI  - Chemical communications.\nPY  - 1965
CY  - London :\nPB  - Chemical Society.\nER  - )
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq %(TY  - BOOK
TI  - The hypothalamus of the cat; a cytoarchitectonic atlas in the Horsley-Clarke co-ordinate system.
AU  - Bleier, Ruth\nPY  - 1961\nCY  - Baltimore :\nPB  - John Hopkins Press,\nER  - )
      end
    end
  end
end
