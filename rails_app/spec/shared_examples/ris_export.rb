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
        expect(object.export_as_ris).to eq <<~RIS.chomp("\n")
          TY  - BOOK
          TI  - Report of the Conference of FAO : nineteenth session, Rome, 12 November - 1 December 1977.
          PY  - 1979
          CY  - Rome
          PB  - The Organization
          ER  - 
        RIS
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq <<~RIS.chomp("\n")
          TY  - GEN
          TI  - GEOBASE
          A2  - Elsevier Science (Firm)
          A2  - Geo Abstracts, Ltd.
          PY  - 1900
          CY  - New York
          PB  - Elsevier Science
          ER  - 
        RIS
      end
    end

    context 'with an electronic journal' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq <<~RIS.chomp("\n")
          TY  - JOUR
          TI  - Nature.
          A2  - Nature Publishing Group
          PY  - 1869
          CY  - London
          PB  - Nature Pub. Group
          ER  - 
        RIS
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq <<~RIS.chomp("\n")
          TY  - JOUR
          TI  - Chemical communications.
          A2  - Chemical Society (Great Britain)
          PY  - 1965
          CY  - London
          PB  - Chemical Society
          ER  - 
        RIS
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns RIS text' do
        expect(object.export_as_ris).to eq <<~RIS.chomp("\n")
          TY  - BOOK
          TI  - The hypothalamus of the cat; a cytoarchitectonic atlas in the Horsley-Clarke co-ordinate system.
          AU  - Bleier, Ruth
          PY  - 1961
          CY  - Baltimore
          PB  - John Hopkins Press
          ER  - 
        RIS
      end
    end
  end
end
