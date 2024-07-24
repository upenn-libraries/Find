# frozen_string_literal: true

# Examples for the RIS format on the six fixtures
shared_examples_for 'RisExport' do
  include FixtureHelpers

  # Test the three RIS on the six fixtures: conference, electronic_database, electronic_journal,
  # print_journal, print_monograph, and record_with_added_date
  # 1. conference
  describe 'RIS on conference fixture' do
    let(:marcxml) { JSON.parse(json_fixture('conference'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - CONFERENCE/EVENT', 'TY  - GOVERNMENT DOCUMENT', 'TY  - BOOK',
                                  'TI  - Report of the Conference of FAO : nineteenth session, Rome, ',
                                  '12 November - 1 December 1977.',
                                  'PY  - 1979', 'CY  - Rome :', 'PB  - The Organization,', 'ER  - '
      end
    end
  end

  # 2. electronic database
  describe 'RIS on electronic database' do
    let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - WEBSITE/DATABASE', 'TY  - DATABASE & ARTICLE INDEX',
                                  'TI  - GEOBASE', 'PY  - 1900', 'CY  - New York :',
                                  'PB  - Elsevier Science.', 'ER  - '
      end
    end
  end

  # 3. electronic journal
  describe 'RIS on electronic journal' do
    let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - JOURNAL/PERIODICAL', 'TI  - Nature.', 'PY  - 1869', 'CY  - [London] :',
                                  'PB  - Nature Pub. Group', 'ER  - '
      end
    end
  end

  # 4. print journal
  describe 'RIS on print journal' do
    let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - JOURNAL/PERIODICAL', 'TI  - Chemical communications.',
                                  'PY  - 1965', 'CY  - London :', 'PB  - Chemical Society.', 'ER  - '
      end
    end
  end

  # 5. print monograph
  describe 'RIS on print monograph' do
    let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - BOOK',
                                  'TI  - The hypothalamus of the cat; a cytoarchitectonic atlas in the Horsley-Clarke',
                                  'AU  - Bleier, Ruth', 'PY  - 1961', 'CY  - Baltimore :',
                                  'PB  - John Hopkins Press,', 'ER  - '
      end
    end
  end

  # 6. record with added date
  describe 'RIS on record with added date' do
    let(:marcxml) { JSON.parse(json_fixture('record_with_added_date'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_ris' do
      it 'returns RIS text' do
        values = object.export_as_ris
        expect(values).to include 'TY  - BOOK', 'TI  - The types of international folktales : a classification and ',
                                  'PY  - 2004', 'CY  - Helsinki :', 'SN  - 9514109627', 'SN  - 9514109635',
                                  'PB  - Suomalainen Tiedeakatemia, Academia Scientiarum Fennica,',
                                  'SN  - 9514109554', 'SN  - 9514109562', 'SN  - 9514109619'
      end
    end
  end
end
