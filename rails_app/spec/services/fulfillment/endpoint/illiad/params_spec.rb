# frozen_string_literal: true

describe Fulfillment::Endpoint::Illiad::Params do
  let(:open_params) { { title: 'Gone with the Wind' } }
  let(:params) { described_class.new(open_params) }

  describe '.new' do
    it 'sets open_params' do
      expect(params.open_params).to eql open_params
    end
  end

  # NOTE: Here we skipped testing methods that are just doing simple lookups with the #search method.

  describe '#request_type' do
    context 'when genre is "unknown"' do
      let(:open_params) { { 'genre' => 'unknown' } }

      it 'returns book' do
        expect(params.request_type).to eql 'book'
      end
    end

    context 'when no requesttype or genre is set' do
      let(:open_params) { {} }

      it 'returns Article' do
        expect(params.request_type).to eql 'article'
      end
    end

    context 'when type is "issue"' do
      let(:open_params) { { 'requesttype' => 'issue' } }

      it 'returns article' do
        expect(params.request_type).to eql 'article'
      end
    end

    context 'when type "Book" is titlecase' do
      let(:open_params) { { 'requesttype' => 'Book' } }

      it 'return "book" in downcase' do
        expect(params.request_type).to eql 'book'
      end
    end
  end

  describe '#author' do
    context 'when author is only provided in separate first name and last name fields' do
      let(:open_params) { { 'rft.aulast' => 'Mitchell', 'rft.aufirst' => 'Margaret' } }

      it 'returns full author name' do
        expect(params.author).to eql 'Mitchell,Margaret'
      end
    end

    context 'when full author name is provided in au field' do
      let(:open_params) { { 'au' => 'Margaret Mitchell', 'rft.aulast' => 'Mitchell', 'rft.aufirst' => 'Margaret' } }

      it 'returns full author name' do
        expect(params.author).to eql 'Margaret Mitchell'
      end
    end
  end

  describe '#journal' do
    context 'when request type is bookitem' do
      context 'when bookTitle is set' do
        let(:open_params) do
          { 'requesttype' => 'bookitem',
            'bookTitle' => 'Gone with the Wind',
            'journal' => 'Gone with the Wind Journal' }
        end

        it 'returns bookTitle' do
          expect(params.journal).to eql 'Gone with the Wind'
        end
      end

      context 'when bookTitle is not set' do
        let(:open_params) do
          { 'requesttype' => 'bookitem', 'bookTitle' => nil, 'journal' => 'Gone with the Wind Journal' }
        end

        it 'returns journal title' do
          expect(params.journal).to eql 'Gone with the Wind Journal'
        end
      end
    end

    context 'when request type is not bookitem' do
      let(:open_params) { { 'bookTitle' => 'Gone with the Wind', 'journal' => 'Gone with the Wind Journal' } }

      it 'returns journal title' do
        expect(params.journal).to eql 'Gone with the Wind Journal'
      end
    end
  end

  describe '#year' do
    context 'when a book request from borrow direct' do
      let(:open_params) { { 'bd' => 'true', 'requesttype' => 'book', 'year' => '2020', 'rftdate' => '2021' } }

      it 'returns date instead of year' do
        expect(params.year).to eql '2021'
      end
    end

    context 'when a book request' do
      let(:open_params) { { 'year' => '2020', 'rft_date' => '2021' } }

      it 'returns year' do
        expect(params.year).to eql '2020'
      end
    end
  end

  describe '#pages' do
    context 'when start and end page numbers provided in different values' do
      let(:open_params) { { 'spage' => '1', 'epage' => '25' } }

      it 'combines start and end page numbers' do
        expect(params.pages).to eql '1-25'
      end
    end

    context 'when page numbers provided in a single field' do
      let(:open_params) { { 'pages' => '26-50', 'spage' => '1', 'epage' => '25' } }

      it 'returns page numbers' do
        expect(params.pages).to eql '26-50'
      end
    end

    context 'when "pages" and "Pages" field provided' do
      let(:open_params) { { 'pages' => '26-50', 'Pages' => '1-25' } }

      it 'preferred "pages" field' do
        expect(params.pages).to eql '26-50'
      end
    end
  end

  describe '#pmid' do
    let(:open_params) { { 'rft_id' => 'pmid:123456' } }

    it 'returns pubmed identifier' do
      expect(params.pmid).to eql '123456'
    end
  end

  describe '#borrow_direct?' do
    context 'when "bd" value is set' do
      let(:open_params) { { 'bd' => 'true' } }

      it 'returns true' do
        expect(params.borrow_direct?).to be true
      end
    end

    context 'when "sid" value is set' do
      let(:open_params) { { 'sid' => 'BD' } }

      it 'returns true' do
        expect(params.borrow_direct?).to be true
      end
    end

    context 'when no expected borrow direct flag is present' do
      let(:open_params) { { 'sid' => 'not-bd' } }

      it 'returns false' do
        expect(params.borrow_direct?).to be false
      end
    end
  end

  describe '#loan?' do
    context 'when open params blank' do
      let(:open_params) { {} }

      it 'returns false' do
        expect(params.loan?).to be false
      end
    end

    context 'when request type is book' do
      let(:open_params) { { 'requesttype' => 'book' } }

      it 'returns true' do
        expect(params.loan?).to be true
      end
    end

    context 'when request type is article' do
      let(:open_params) { { 'requesttype' => 'article' } }

      it 'returns false' do
        expect(params.loan?).to be false
      end
    end
  end

  describe '#scan?' do
    context 'when open params blank' do
      let(:open_params) { {} }

      it 'returns false' do
        expect(params.scan?).to be false
      end
    end

    context 'when request type is book' do
      let(:open_params) { { 'requesttype' => 'book' } }

      it 'returns false' do
        expect(params.scan?).to be false
      end
    end

    context 'when request type is article' do
      let(:open_params) { { 'requesttype' => 'article' } }

      it 'returns true' do
        expect(params.scan?).to be true
      end
    end

    context 'when request type is a non-article non-book type' do
      let(:open_params) { { 'requesttype' => 'conference' } }

      it 'returns true' do
        expect(params.scan?).to be true
      end
    end
  end

  describe '#search' do
    context 'when keys contain blank values' do
      let(:open_params) { { 'author' => nil, 'au' => '', 'Author' => 'Random Author' } }

      it 'chooses the first non-blank value' do
        expect(params.search('author', 'au', 'rft.au', 'Author')).to eql 'Random Author'
      end
    end

    context 'when some keys are not present in hash' do
      let(:open_params) { { 'au' => 'Random Author', 'Author' => 'Other Random Author' } }

      it 'returns the first value that is present' do
        expect(params.search('author', 'au', 'rft.au', 'Author')).to eql 'Random Author'
      end
    end

    context 'when none of the keys are present' do
      let(:open_params) { { 'au' => 'Random Author', 'Author' => 'Other Random Author' } }

      it 'returns nil' do
        expect(params.search('author', 'rft.au')).to be nil
      end
    end
  end
end
