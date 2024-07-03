# frozen_string_literal: true

require 'rails_helper'

describe SolrDocument do
  include FixtureHelpers

  let(:marcxml) { JSON.parse(json_fixture('solrdocument'))['marcxml_marcxml'].first }
  let(:source) { { id: '9918724353503681', marcxml_marcxml: marcxml } }
  let(:object) { described_class.new(source) }

  it_behaves_like 'MARCParsing'

  describe '.export_as_mla_citation_txt' do
    it 'returns MLA citation text' do
      values = object.export_as_mla_citation_txt
      expect(values).to include 'Hofmannsthal, Hugo von, et al.',
                                '<i>Die Frau ohne Schatten : opera in three acts. </i>',
                                'London : London : Decca ; New York, N.Y. :',
                                'manufactured for and marketed by Polygram Records, Inc., [1993, c1992]'
    end
  end

  describe '.export_as_apa_citation_txt' do
    it 'returns APA citation text' do
      values = object.export_as_apa_citation_txt
      expect(values).to include 'Hofmannsthal, H. von, Friedrich, G., Studer, C., Moser, T.',
                                '<i>Die Frau ohne Schatten : opera in three acts. </i>', '(1993)',
                                'London : London : Decca ; New York, N.Y. : ',
                                'manufactured for and marketed by Polygram Records, Inc.'
    end
  end

  describe '.export_as_chicago_citation_txt' do
    it 'returns Chicago citation text' do
      values = object.export_as_chicago_citation_txt
      expect(values).to include 'Hofmannsthal, Hugo von', 'Thomas Moser, Eva Marton, Robert Hale',
                                'Marjana Lipovšek, et al.', '<i>Die Frau ohne Schatten : opera in three acts. </i>',
                                'London : London : Decca ; New York, N.Y. :',
                                'manufactured for and marketed by Polygram Records, Inc., [1993, c1992]'
    end
  end

  describe '.export_as_ris' do
    it 'returns RIS format' do
      values = object.export_as_ris
      expect(values).to include 'TY  - CONFERENCE/EVENTVIDEO', 'TI  - Die Frau ohne Schatten : opera in three acts',
                                'PY  - 1993', 'London : New York, N.Y. :',
                                'PB  - London : Decca ; manufactured for and marketed by Polygram Records, Inc.,'
    end
  end
end
