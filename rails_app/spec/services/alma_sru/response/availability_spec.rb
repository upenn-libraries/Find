describe AlmaSRU::Response::Availability do
  subject { described_class.new(response_body) }

  let(:response_body) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?><searchRetrieveResponse xmlns="http://www.loc.gov/zing/srw/">
        <version>1.2</version>
        <numberOfRecords>1</numberOfRecords>
        <records>
          <record>
            <recordSchema>marcxml</recordSchema>
            <recordPacking>xml</recordPacking>
            <recordData>
              <record xmlns="http://www.loc.gov/MARC21/slim">
                <leader>03605cam a2200445 a 4500</leader>
                <controlfield tag="001">999763063503681</controlfield>
                <controlfield tag="005">20220609182420.0</controlfield>
                <controlfield tag="008">890317s1989    enk      b    001 0 eng^^</controlfield>
                <datafield ind1=" " ind2=" " tag="010">
                  <subfield code="a">88023358</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="020">
                  <subfield code="a">0521353815</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="020">
                  <subfield code="a">0521367816</subfield>
                  <subfield code="q">paperback</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">(OCoLC)ocm18290785</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">(OCoLC)18290785</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">(CStRLIN)PAUG89-B10121</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">(CaOTULAS)185151274</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="9">AFU4124</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">976306</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="035">
                  <subfield code="a">(PU)976306-penndb-Voyager</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="040">
                  <subfield code="b">eng</subfield>
                  <subfield code="d">NNC</subfield>
                  <subfield code="d">CU-SB</subfield>
                </datafield>
                <datafield ind1="0" ind2=" " tag="050">
                  <subfield code="a">P106</subfield>
                  <subfield code="b">.R586 1989</subfield>
                </datafield>
                <datafield ind1="0" ind2=" " tag="082">
                  <subfield code="a">401</subfield>
                  <subfield code="2">19</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="090">
                  <subfield code="a">P106</subfield>
                  <subfield code="b">.R586 1989</subfield>
                  <subfield code="i">03/17/89 CTZ</subfield>
                </datafield>
                <datafield ind1="1" ind2=" " tag="100">
                  <subfield code="a">Rorty, Richard.</subfield>
                  <subfield code="0">http://id.loc.gov/authorities/names/n79063821</subfield>
                </datafield>
                <datafield ind1="1" ind2="0" tag="245">
                  <subfield code="a">Contingency, irony, and solidarity /</subfield>
                  <subfield code="c">Richard Rorty.</subfield>
                </datafield>
                <datafield ind1=" " ind2="1" tag="264">
                  <subfield code="a">Cambridge ;</subfield>
                  <subfield code="a">New York :</subfield>
                  <subfield code="b">Cambridge University Press,</subfield>
                  <subfield code="c">1989.</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="300">
                  <subfield code="a">xvi, 201 pages ;</subfield>
                  <subfield code="c">24 cm</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="336">
                  <subfield code="a">text</subfield>
                  <subfield code="b">txt</subfield>
                  <subfield code="2">rdacontent</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="337">
                  <subfield code="a">unmediated</subfield>
                  <subfield code="b">n</subfield>
                  <subfield code="2">rdamedia</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="338">
                  <subfield code="a">volume</subfield>
                  <subfield code="b">nc</subfield>
                  <subfield code="2">rdacarrier</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="500">
                  <subfield code="a">Includes bibliographical references and index.</subfield>
                </datafield>
                <datafield ind1="0" ind2="0" tag="505">
                  <subfield code="g">Part I</subfield>
                  <subfield code="t">Contingency --</subfield>
                  <subfield code="g">1</subfield>
                  <subfield code="t">The contingency of language</subfield>
                  <subfield code="g">3 --</subfield>
                  <subfield code="g">2</subfield>
                  <subfield code="t">The contingency of selfhood</subfield>
                  <subfield code="g">23 --</subfield>
                  <subfield code="g">3</subfield>
                  <subfield code="t">The contingency of a liberal community</subfield>
                  <subfield code="g">44 --</subfield>
                  <subfield code="g">Part II</subfield>
                  <subfield code="t">Ironism and Theory --</subfield>
                  <subfield code="g">4</subfield>
                  <subfield code="t">Private irony and liberal hope</subfield>
                  <subfield code="g">73 --</subfield>
                  <subfield code="g">5</subfield>
                  <subfield code="t">Self-creation and affiliation: Proust, Nietzsche, and Heidegger</subfield>
                  <subfield code="g">96 --</subfield>
                  <subfield code="g">6</subfield>
                  <subfield code="t">From ironist theory to private allusions: Derrida</subfield>
                  <subfield code="g">122 --</subfield>
                  <subfield code="g">Part III</subfield>
                  <subfield code="t">Cruelty and Solidarity --</subfield>
                  <subfield code="g">7</subfield>
                  <subfield code="t">The barber of Kasbeam: Nabokov on cruelty</subfield>
                  <subfield code="g">141 --</subfield>
                  <subfield code="g">8</subfield>
                  <subfield code="t">The last intellectual in Europe: Orwell on cruelty</subfield>
                  <subfield code="g">169 --</subfield>
                  <subfield code="g">9</subfield>
                  <subfield code="t">Solidarity</subfield>
                  <subfield code="g">189.</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="520">
                  <subfield code="a">Richard Rorty is one of the most provocative and influential thinkers of our time. His sustained critique of the foundationalist, metaphysical aspirations of philosophy has had a galvanizing effect both inside and outside philosophy departments, and has led Harold Bloom to describe him as "the most interesting philosopher in the world today."</subfield>
                </datafield>
                <datafield ind1="8" ind2=" " tag="520">
                  <subfield code="a">In his new book Rorty argues that thinkers such as Nietzsche, Freud, and Wittgenstein have enabled societies to see themselves as historical contingencies, rather than as expressions of underlying, ahistorical human nature or as realizations of suprahistorical goals. This ironic perspective on the human condition is valuable on a private level, although it cannot advance the social or political goals of liberalism. In fact Rorty believes that it is literature not philosophy that can do this, by promoting a genuine sense of human solidarity. Specifically, novelists such as Orwell and Nabokov (both discussed in detail in the book) succeed in awakening us to the humiliation and cruelty of particular social practices and individual attitudes. A truly liberal culture, acutely aware of its own historical contingency, would fuse the private, individual freedom of the ironic, philosophical perspective with the public project of human solidarity as it is engendered through the insights and sensibilities of great writers.</subfield>
                </datafield>
                <datafield ind1="8" ind2=" " tag="520">
                  <subfield code="a">The book has a characteristically wide range of reference from philosophy through social theory to literary criticism. It confirms Rorty's status as a uniquely subtle theorist, whose writing will prove absorbing to academic and nonacademic readers alike.</subfield>
                </datafield>
                <datafield ind1=" " ind2="0" tag="650">
                  <subfield code="a">Language and languages</subfield>
                  <subfield code="x">Philosophy.</subfield>
                  <subfield code="0">http://id.loc.gov/authorities/subjects/sh85074574</subfield>
                </datafield>
                <datafield ind1=" " ind2="7" tag="650">
                  <subfield code="a">Language and languages</subfield>
                  <subfield code="x">Philosophy.</subfield>
                  <subfield code="2">fast</subfield>
                  <subfield code="0">http://id.worldcat.org/fast/992193</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="902">
                  <subfield code="a">MARCIVE 2022</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="948">
                  <subfield code="a">loc:msf</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="950">
                  <subfield code="l">VPL</subfield>
                  <subfield code="i">03/17/89 C</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="955">
                  <subfield code="l">VPL</subfield>
                  <subfield code="c">1</subfield>
                  <subfield code="q">YAP</subfield>
                  <subfield code="r">[00892 0998]</subfield>
                  <subfield code="i">03/17/89 C</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="AVA">
                  <subfield code="0">999763063503681</subfield>
                  <subfield code="8">22355842850003681</subfield>
                  <subfield code="a">01UPENN_INST</subfield>
                  <subfield code="b">AnnenLib</subfield>
                  <subfield code="c">Reserves</subfield>
                  <subfield code="d">P106 .R586 1989</subfield>
                  <subfield code="e">available</subfield>
                  <subfield code="f">1</subfield>
                  <subfield code="g">0</subfield>
                  <subfield code="j">annbrese</subfield>
                  <subfield code="k">0</subfield>
                  <subfield code="p">1</subfield>
                  <subfield code="q">Annenberg Library</subfield>
                </datafield>
                <datafield ind1=" " ind2=" " tag="AVA">
                  <subfield code="0">999763063503681</subfield>
                  <subfield code="8">22355842870003681</subfield>
                  <subfield code="a">01UPENN_INST</subfield>
                  <subfield code="b">VanPeltLib</subfield>
                  <subfield code="c">Stacks</subfield>
                  <subfield code="d">P106 .R586 1989</subfield>
                  <subfield code="e">available</subfield>
                  <subfield code="f">1</subfield>
                  <subfield code="g">0</subfield>
                  <subfield code="j">vanp</subfield>
                  <subfield code="k">0</subfield>
                  <subfield code="p">2</subfield>
                  <subfield code="q">Van Pelt Library</subfield>
                </datafield>
              </record>
            </recordData>
            <recordIdentifier>999763063503681</recordIdentifier>
            <recordPosition>1</recordPosition>
          </record>
        </records>
        <extraResponseData xmlns:xb="http://www.exlibris.com/repository/search/xmlbeans/">
          <xb:exact>true</xb:exact>
          <xb:responseDate>2025-06-17T14:33:32-0400</xb:responseDate>
        </extraResponseData>
      </searchRetrieveResponse>
    XML
  end

  describe '#holdings' do
    context 'with a print record' do
      it 'returns expected data' do
        expect(subject.holdings.first).to eq({})
      end
    end

    xcontext 'with an electronic record' do

    end
  end
end
