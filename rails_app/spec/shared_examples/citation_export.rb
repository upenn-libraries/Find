# frozen_string_literal: true

# Examples for the three citations on the six fixtures, and examples for format_authors method
shared_examples_for 'CitationExport' do
  include FixtureHelpers

  # Test the three citations on the six fixtures: conference, electronic_database, electronic_journal,
  # print_journal, print_monograph, and record_with_added_date
  # 1. conference
  describe 'Citations on conference fixture' do
    let(:marcxml) { JSON.parse(json_fixture('conference'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include '<i>Report of the Conference of FAO : ',
                                  'nineteenth session, Rome, 12 November - 1 December 1977. </i>',
                                  'Rome : The Organization, 1977.'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include '(1979)',
                                  '<i>Report of the Conference of FAO : ',
                                  'nineteenth session, Rome, 12 November - 1 December 1977. </i>',
                                  'Rome : The Organization.'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include '<i>Report of the Conference of FAO : ',
                                  'nineteenth session, Rome, 12 November - 1 December 1977. </i>',
                                  'Rome : The Organization, 1977.'
      end
    end
  end

  # 2. electronic database
  describe 'Citations on electronic database' do
    let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include 'Elsevier Science (Firm) and Ltd. Geo Abstracts.',
                                  '<i>GEOBASE. </i>',
                                  '>New York : Elsevier Science.'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include '(1900)',
                                  'Elsevier Science (Firm), E. Science (Firm) &amp; Geo Abstracts, L.',
                                  '<i>GEOBASE. </i>',
                                  'New York : Elsevier Science.'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include 'Elsevier Science (Firm) and Ltd. Geo Abstracts.',
                                  '<i>GEOBASE. </i>',
                                  '>New York : Elsevier Science.'
      end
    end
  end

  # 3. electronic journal
  describe 'Citations on electronic journal' do
    let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include '<i>Nature. </i>',
                                  'Nature Publishing Group. ',
                                  '[London] : Nature Pub. Group'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include '(1869)',
                                  'Nature Publishing Group',
                                  '<i>Nature. </i>',
                                  '[London] : Nature Pub. Group'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include 'Nature Publishing Group',
                                  '<i>Nature. </i>',
                                  '[London] : Nature Pub. Group'
      end
    end
  end

  # 4. electronic journal
  describe 'Citations on print journal' do
    let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include 'Chemical Society (Great Britain) and Chemical Society (Great Britain).',
                                  '<i>Chemical communications. </i>',
                                  'London : Chemical Society.'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include '(1965).', 'Chemical Society (Great Britain), C. Society (Great Britain)',
                                  ' &amp; Chemical Society (Great Britain)., C. Society (Great Britain). ',
                                  ' <i>Chemical communications. </i>',
                                  'London : Chemical Society.'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include 'Chemical Society (Great Britain) and Chemical Society (Great Britain).',
                                  '<i>Chemical communications. </i>',
                                  'London : Chemical Society.'
      end
    end
  end

  # 5. electronic journal
  describe 'Citations on print monograph' do
    let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include 'Bleier, Ruth.',
                                  '<i>The hypothalamus of the cat; a cytoarchitectonic atlas',
                                  'in the Horsley-Clarke co-ordinate system. </i>',
                                  'Baltimore : John Hopkins Press, [1961]'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include 'Bleier, R.', '(1961).',
                                  '<i>The hypothalamus of the cat; a cytoarchitectonic atlas',
                                  'in the Horsley-Clarke co-ordinate system. </i>',
                                  'Baltimore : John Hopkins Press.'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include 'Bleier, Ruth.',
                                  '<i>The hypothalamus of the cat; a cytoarchitectonic atlas',
                                  'in the Horsley-Clarke co-ordinate system. </i>',
                                  'Baltimore : John Hopkins Press, [1961]'
      end
    end
  end

  # 6. electronic journal
  describe 'Citations on record with added date' do
    let(:marcxml) { JSON.parse(json_fixture('record_with_added_date'))['marcxml_marcxml'].first }
    let(:source) { { marcxml_marcxml: marcxml } }
    let(:object) { described_class.new(source) }

    describe '.export_as_mla_citation_txt' do
      it 'returns MLA citation text' do
        values = object.export_as_mla_citation_txt
        expect(values).to include 'Uther, Hans-Jörg., Folklore Fellows. and Alumni and Friends Memorial Book Fund.',
                                  '<i>The types of international folktales : a classification and bibliography, ',
                                  'based on the system of Antti Aarne and Stith Thompson. </i>',
                                  'Helsinki : Suomalainen Tiedeakatemia, Academia Scientiarum Fennica, [2004]'
      end
    end

    describe '.export_as_apa_citation_txt' do
      it 'returns APA citation text' do
        values = object.export_as_apa_citation_txt
        expect(values).to include 'Uther, H., Folklore Fellows., F. Fellows. &amp; ',
                                  'Alumni and Friends Memorial Book Fund.', '<i>The types of international ',
                                  'Helsinki : Suomalainen Tiedeakatemia, Academia Scientiarum Fennica'
      end
    end

    describe '.export_as_chicago_citation_txt' do
      it 'returns Chicago citation text' do
        values = object.export_as_chicago_citation_txt
        expect(values).to include 'Uther, Hans-Jörg., Folklore Fellows. and Alumni and Friends Memorial Book Fund.',
                                  '<i>The types of international folktales : a classification and bibliography, ',
                                  'based on the system of Antti Aarne and Stith Thompson. </i>',
                                  'Helsinki : Suomalainen Tiedeakatemia, Academia Scientiarum Fennica, [2004]'
      end
    end
  end

  include CitationExport

  # Test of private method format_names
  describe 'format authors with 3 authors' do
    let(:authors) { ['One, First', 'Two, Second', 'Three, Third'] }
    let(:apa_authors) { ['One, F.', 'Two, S.', 'Three, T.'] }

    describe 'for MLA with 3 authors' do
      it 'returns MLA author list' do
        values = format_authors(authors, :mla)
        expect(values).to eq 'One, First, Second Two and Third Three. '
      end
    end

    describe 'for APA with 3 authors' do
      it 'returns APA author list' do
        values = format_authors(apa_authors, :apa)
        expect(values).to eq 'One, F., Two, S. &amp; Three, T. '
      end
    end

    describe 'for Chicago with 3 authors' do
      it 'returns APA author list' do
        values = format_authors(authors, :chicago)
        expect(values).to eq 'One, First, Second Two and Third Three. '
      end
    end
  end

  describe 'format authors with 8 authors' do
    let(:authors) do
      ['One, First', 'Two, Second', 'Three, Third', 'Four, Forth',
       'Five, Fifth', 'Six, Sixth', 'Seven, Seventh', 'Eight, Eighth']
    end
    let(:apa_authors) do
      ['One, F.', 'Two, S.', 'Three, T.', 'Four, F.',
       'Five, F.', 'Six, S.', 'Seven, S.', 'Eight, E.']
    end

    describe 'for MLA with 8 authors' do
      it 'returns MLA author list' do
        values = format_authors(authors, :mla)
        expect(values).to eq 'One, First, et al. '
      end
    end

    describe 'for APA with 8 authors' do
      it 'returns APA author list' do
        values = format_authors(apa_authors, :apa)
        expect(values).to eq 'One, F., Two, S., Three, T., Four, F., Five, F., Six, S., Seven, S. &amp; Eight, E. '
      end
    end

    describe 'for Chicago with 8 authors' do
      it 'returns APA author list' do
        values = format_authors(authors, :chicago)
        expect(values).to eq 'One, First, Second Two, Third Three, Forth Four, Fifth Five, Sixth Six and' \
                               ' Seventh Seven, et al. '
      end
    end
  end
end
