# frozen_string_literal: true

# Examples for the three citations on the six fixtures, and examples for format_authors method
shared_examples_for 'CitationExport' do
  include FixtureHelpers

  # Test the three citations on the five fixtures: conference, electronic_database, electronic_journal,
  # print_journal, and print_monograph
  # 1. conference
  let(:source) { { marcxml_marcxml: marcxml } }
  let(:object) { described_class.new(source) }
  let(:marcxml) { JSON.parse(json_fixture('conference'))['marcxml_marcxml'].first }

  describe '#export_as_mla_citation_txt' do
    context 'with a conference record' do
      it 'returns MLA citation text' do
        value = object.export_as_mla_citation_txt
        expect(value).to eq '<i>Report of the Conference of FAO : nineteenth session, Rome, 12 November - ' \
                              '1 December 1977. </i>Rome : The Organization, 1977.'
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns MLA citation text' do
        value = object.export_as_mla_citation_txt
        expect(value).to eq 'Elsevier Science (Firm) and Ltd. Geo Abstracts. <i>GEOBASE. </i>' \
                              'New York : Elsevier Science.'
      end
    end

    context 'with an electronic journal record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns MLA citation text' do
        value = object.export_as_mla_citation_txt
        expect(value).to eq 'Nature Publishing Group. <i>Nature. </i>[London] : Nature Pub. Group'
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns MLA citation text' do
        value = object.export_as_mla_citation_txt
        expect(value).to eq 'Chemical Society (Great Britain) and Chemical Society (Great Britain). ' \
                              '<i>Chemical communications. </i>London : Chemical Society.'
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns MLA citation text' do
        value = object.export_as_mla_citation_txt
        expect(value).to eq 'Bleier, Ruth. <i>The hypothalamus of the cat; a cytoarchitectonic atlas ' \
                              'in the Horsley-Clarke co-ordinate system. </i>Baltimore : John Hopkins Press, [1961]'
      end
    end
  end

  describe '#export_as_apa_citation_txt' do
    context 'with a conference record' do
      it 'returns APA citation text' do
        value = object.export_as_apa_citation_txt
        expect(value).to eq '(1979). <i>Report of the Conference of FAO : ' \
                              'nineteenth session, Rome, 12 November - 1 December 1977. </i>' \
                              'Rome : The Organization.'
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns APA citation text' do
        value = object.export_as_apa_citation_txt
        expect(value).to eq 'Elsevier Science (Firm) &amp; Geo Abstracts, L. (1900). ' \
                              '<i>GEOBASE. </i>New York : Elsevier Science.'
      end
    end

    context 'with an electronic journal record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns APA citation text' do
        value = object.export_as_apa_citation_txt
        expect(value).to eq 'Nature Publishing Group. (1869). <i>Nature. </i>[London] : Nature Pub. Group.'
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns APA citation text' do
        value = object.export_as_apa_citation_txt
        expect(value).to eq 'Chemical Society (Great Britain) &amp; Chemical Society (Great Britain). (1965).' \
                              ' <i>Chemical communications. </i>London : Chemical Society.'
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns APA citation text' do
        value = object.export_as_apa_citation_txt
        expect(value).to eq 'Bleier, R. (1961). <i>The hypothalamus of the cat; ' \
                              'a cytoarchitectonic atlas in the Horsley-Clarke co-ordinate system. ' \
                              '</i>Baltimore : John Hopkins Press.'
      end
    end
  end

  describe '#export_as_chicago_citation_txt' do
    context 'with a conference record' do
      it 'returns Chicago citation text' do
        value = object.export_as_chicago_citation_txt
        expect(value).to eq '<i>Report of the Conference of FAO : ' \
                              'nineteenth session, Rome, 12 November - 1 December 1977. </i>' \
                              'Rome : The Organization, 1977.'
      end
    end

    context 'with an electronic database record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_database'))['marcxml_marcxml'].first }

      it 'returns Chicago citation text' do
        value = object.export_as_chicago_citation_txt
        expect(value).to eq 'Elsevier Science (Firm) and Ltd. Geo Abstracts. <i>GEOBASE. </i>' \
                              'New York : Elsevier Science.'
      end
    end

    context 'with an electronic journal record' do
      let(:marcxml) { JSON.parse(json_fixture('electronic_journal'))['marcxml_marcxml'].first }

      it 'returns Chicago citation text' do
        value = object.export_as_chicago_citation_txt
        expect(value).to eq 'Nature Publishing Group. <i>Nature. </i>[London] : Nature Pub. Group'
      end
    end

    context 'with a print journal record' do
      let(:marcxml) { JSON.parse(json_fixture('print_journal'))['marcxml_marcxml'].first }

      it 'returns Chicago citation text' do
        value = object.export_as_chicago_citation_txt
        expect(value).to eq 'Chemical Society (Great Britain) and Chemical Society (Great Britain). ' \
                              '<i>Chemical communications. </i>London : Chemical Society.'
      end
    end

    context 'with a print monograph record' do
      let(:marcxml) { JSON.parse(json_fixture('print_monograph'))['marcxml_marcxml'].first }

      it 'returns Chicago citation text' do
        value = object.export_as_chicago_citation_txt
        expect(value).to eq 'Bleier, Ruth. <i>The hypothalamus of the cat; a cytoarchitectonic atlas ' \
                              'in the Horsley-Clarke co-ordinate system. </i>Baltimore : John Hopkins Press, [1961]'
      end
    end
  end

  # Test of private method format_authors
  describe '#format authors' do
    context 'with 3 authors' do
      let(:authors) { ['One, First', 'Two, Second', 'Three, Third'] }
      let(:apa_authors) { ['One, F.', 'Two, S.', 'Three, T.'] }

      context 'when MLA' do
        it 'returns MLA author list' do
          expect(object.send(:format_authors, authors, :mla)).to eq 'One, First, Second Two and Third Three. '
        end
      end

      context 'when APA' do
        it 'returns APA author list' do
          expect(object.send(:format_authors, apa_authors, :apa)).to eq 'One, F., Two, S. &amp; Three, T. '
        end
      end

      context 'when Chicago' do
        it 'returns Chicago author list' do
          expect(object.send(:format_authors, authors, :chicago)).to eq 'One, First, Second Two and Third Three. '
        end
      end
    end

    context 'with 8 authors' do
      let(:authors) do
        ['One, First', 'Two, Second', 'Three, Third', 'Four, Forth',
         'Five, Fifth', 'Six, Sixth', 'Seven, Seventh', 'Eight, Eighth']
      end
      let(:apa_authors) do
        ['One, F.', 'Two, S.', 'Three, T.', 'Four, F.',
         'Five, F.', 'Six, S.', 'Seven, S.', 'Eight, E.']
      end

      context 'when MLA citation' do
        it 'returns MLA author list' do
          expect(object.send(:format_authors, authors, :mla)).to eq 'One, First, et al. '
        end
      end

      context 'when APA citation' do
        it 'returns APA author list' do
          expect(object.send(:format_authors, apa_authors, :apa)).to eq 'One, F., Two, S., Three, T., ' \
                                        'Four, F., Five, F., Six, S., Seven, S. &amp; Eight, E. '
        end
      end

      context 'when Chicago citation' do
        it 'returns Chicago author list' do
          expect(object.send(:format_authors, authors, :chicago)).to eq 'One, First, Second Two, Third Three, ' \
                                                       'Forth Four, Fifth Five, Sixth Six and Seventh Seven, et al. '
        end
      end
    end
  end

  # Test of private method convert_name_order
  describe '#convert_name_order' do
    context 'with last, first' do
      it 'returns First Last' do
        expect(object.send(:convert_name_order, 'Last, First')).to eq 'First Last'
      end
    end

    context 'with no comma in name' do
      it 'returns the name as is' do
        expect(object.send(:convert_name_order, 'Name with no comma')).to eq 'Name with no comma'
      end
    end

    context 'with name ends in comma' do
      it 'removes the trailing comma' do
        expect(object.send(:convert_name_order, 'Name ends with comma,')).to eq 'Name ends with comma'
      end
    end
  end

  # Test of private method format_contributors
  describe '#format_contributors' do
    context 'with no contributors' do
      it 'returns the contributor with converted name order' do
        expect(object.send(:format_contributors, [], 'Tested')).to eq ''
      end
    end

    context 'with one contributor' do
      it 'returns the contributor with converted name order' do
        expect(object.send(:format_contributors, ['One, First'], 'Tested')).to eq 'Tested by First One. '
      end
    end

    context 'with multiple contributors' do
      it 'returns contributors with converted name order joined by and' do
        value = object.send(:format_contributors,
                            ['One, First', 'Two, Second', 'Three, Third', 'Four, Forth'], 'Tested')
        expect(value).to eq 'Tested by First One and Second Two and Third Three and Forth Four. '
      end
    end
  end

  # Test of private method format_chicago_additional_title
  describe '#format_chicago_additional_title' do
    context 'with non-empty translators, editors and compilers lists' do
      it 'returns all three formatted contributor lists' do
        value = object.send(:format_chicago_additional_title,
                            ['Aaa, Bbb', 'Ccc, Ddd'], ['Eee, Fff', 'Ggg, Hhh'], ['Iii, Jjj', 'Kkk, Lll'])
        expect(value).to eq 'Translated by Bbb Aaa and Ddd Ccc. Edited by Fff Eee and Hhh Ggg. ' \
                              'Compiled by Jjj Iii and Lll Kkk. '
      end
    end

    context 'with empty editors' do
      it 'returns with both translators and compilers' do
        value = object.send(:format_chicago_additional_title,
                            ['Aaa, Bbb', 'Ccc, Ddd'], [], ['Iii, Jjj', 'Kkk, Lll'])
        expect(value).to eq 'Translated by Bbb Aaa and Ddd Ccc. Compiled by Jjj Iii and Lll Kkk. '
      end
    end

    context 'with empty translators, editors and compilers' do
      it 'returns empty' do
        expect(object.send(:format_chicago_additional_title, [], [], [])).to eq ''
      end
    end
  end
end
