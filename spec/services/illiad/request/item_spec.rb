# frozen_string_literal: true

describe Illiad::Request::Item do
  let(:requested_item) { build(:illiad_item, data: data) }

  describe '#title' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns expected title' do
        expect(requested_item.title).to eq data['LoanTitle']
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected title' do
        expect(requested_item.title).to eq data['PhotoJournalTitle']
      end
    end
  end

  describe '#section_title' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns nil' do
        expect(requested_item.section_title).to eq nil
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected section title' do
        expect(requested_item.section_title).to eq data['PhotoArticleTitle']
      end
    end
  end

  describe '#author' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns expected author' do
        expect(requested_item.author).to eq data['LoanAuthor']
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected author' do
        expect(requested_item.author).to eq data['PhotoArticleAuthor']
      end
    end
  end

  describe '#publication_date' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns expected publication date' do
        expect(requested_item.publication_date).to eq data['LoanDate']
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected publication date' do
        expect(requested_item.publication_date).to eq data['PhotoJournalYear']
      end
    end
  end

  describe '#volume' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns nil' do
        expect(requested_item.volume).to eq nil
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected volume' do
        expect(requested_item.volume).to eq data['PhotoJournalVolume']
      end
    end
  end

  describe '#issue' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns nil' do
        expect(requested_item.issue).to eq nil
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected issue' do
        expect(requested_item.issue).to eq data['PhotoJournalIssue']
      end
    end
  end

  describe '#pages' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns nil' do
        expect(requested_item.pages).to eq nil
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected page range' do
        expect(requested_item.pages).to eq data['PhotoJournalInclusivePages']
      end
    end
  end

  describe '#issn' do
    context 'with a request to loan' do
      let(:data) { build(:illiad_loan_request_data) }

      it 'returns expected issn' do
        expect(requested_item.issn).to eq data['ISSN']
      end
    end

    context 'with a request to scan' do
      let(:data) { build(:illiad_scan_request_data) }

      it 'returns expected issn' do
        expect(requested_item.issn).to eq data['ISSN']
      end
    end
  end
end
