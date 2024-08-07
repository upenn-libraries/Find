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
        expect(object.export_as_ris).to eq "TY  - BOOK\n" \
                                             'TI  - Report of the Conference of FAO : nineteenth session, Rome, ' \
                                             "12 November - 1 December 1977.\n" \
                                             "PY  - 1979\nCY  - Rome :\nPB  - The Organization,\nER  - "
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq "TY  - GEN\n" \
                                  "TI  - GEOBASE\nPY  - 1900\nCY  - New York :\n" \
                                  "PB  - Elsevier Science.\nER  - "
      end
    end

    context 'with an electronic journal' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq "TY  - JOUR\nTI  - Nature.\nPY  - 1869\n" \
                                             "CY  - [London] :\nPB  - Nature Pub. Group\nER  - "
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq "TY  - JOUR\nTI  - Chemical communications.\n" \
                                  "PY  - 1965\nCY  - London :\nPB  - Chemical Society.\nER  - "
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq "TY  - BOOK\n" \
          "TI  - The hypothalamus of the cat; a cytoarchitectonic atlas in the Horsley-Clarke co-ordinate system.\n" \
          "AU  - Bleier, Ruth\nPY  - 1961\nCY  - Baltimore :\n" \
          "PB  - John Hopkins Press,\nER  - "
      end
    end

    context 'with a record with added date' do
      let(:marcxml) { JSON.parse(json_fixture('record_with_added_date'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq "TY  - BOOK\nTI  - The types of international folktales : " \
           "a classification and bibliography, based on the system of Antti Aarne and Stith Thompson\n" \
           "AU  - Uther, Hans-Jörg.\nPY  - 2004\nCY  - Helsinki :\nPB  - Suomalainen Tiedeakatemia, Academia " \
           "Scientiarum Fennica,\nSN  - 9514109554\nSN  - 9514109562\nSN  - 9514109619\nSN  - 9514109627\n" \
           "SN  - 9514109635\nSN  - 9514109643\nER  - "
      end
    end
  end
end
