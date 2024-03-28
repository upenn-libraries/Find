# frozen_string_literal: true

describe Illiad::Request do
  let(:illiad_response_data) { build(:illiad_loan_request_data) }
  let(:request) { build(:illiad_request, data: illiad_response_data) }

  include_context 'with stubbed illiad request data'

  describe '.submit' do
    context 'with a successful api request'
    it 'returns an Illiad::Request instance' do
      expect(described_class.submit(data: illiad_response_data)).to be_a(described_class)
    end
  end

  context 'with an unsuccessful api request' do
    include_context 'with stubbed illiad api error'

    it 'raises an error ' do
      expect { described_class.submit(data: illiad_response_data) }.to raise_error(described_class::Error)
    end
  end

  describe '.find' do
    context 'with a successful api request' do
      it 'returns an Illiad::Request instance' do
        expect(described_class.find(id: 1)).to be_a(described_class)
      end
    end

    context 'with an unsuccessful api request' do
      include_context 'with stubbed illiad api error'

      it 'raises an error ' do
        expect { described_class.find(id: 1) }.to raise_error(described_class::Error)
      end
    end
  end

  describe '.cancel' do
    context 'with a successful api request' do
      it 'returns the json data from the Illiad API' do
        expect(described_class.cancel(id: illiad_response_data['TransactionNumber'])).to eq illiad_response_data
      end
    end

    context 'with an unsuccessful api request' do
      include_context 'with stubbed illiad api error'

      it 'raises an error' do
        expect {
          described_class.cancel(id: illiad_response_data['TransactionNumber'])
        }.to raise_error(described_class::Error)
      end
    end
  end

  describe '.add_note' do
    let(:data) { build(:illiad_note_data) }

    context 'with a successful api request' do
      it 'returns the json data from the Illiad API' do
        expect(described_class.add_note(id: illiad_response_data['TransactionNumber'],
                                        note: illiad_response_data['Note'])).to eq illiad_response_data
      end
    end

    context 'with an unsuccessful api request' do
      include_context 'with stubbed illiad api error'
      it 'raises an error ' do
        expect {
          described_class.add_note(id: illiad_response_data['TransactionNumber'], note: illiad_response_data['Note'])
        }.to raise_error(described_class::Error)
      end
    end
  end

  describe '#request_type' do
    it 'returns expected request type' do
      expect(request.request_type).to eq illiad_response_data['RequestType']
    end
  end

  describe '#document_type' do
    it 'returns expected document type' do
      expect(request.document_type).to eq illiad_response_data['DocumentType']
    end
  end

  describe '#status' do
    it 'returns expected status' do
      expect(request.status).to eq illiad_response_data['TransactionStatus']
    end
  end

  describe '#date' do
    it 'returns expected transaction date' do
      expect(request.date).to eq DateTime.parse(illiad_response_data['TransactionDate'])
    end
  end

  describe '#due_date', pending: true do
    it 'returns due date' do
      expect(request.due_date).to eq DateTime.parse(illiad_response_data['DueDate'])
    end
  end

  describe '#loan?' do
    context 'with request to loan' do
      it 'returns true' do
        expect(request.loan?).to be true
      end
    end

    context 'with a request to scan' do
      let(:illiad_response_data) { build(:illiad_scan_request_data) }

      it 'returns false' do
        expect(request.loan?).to be false
      end
    end
  end

  describe '#books_by_mail?' do
    context 'with a books by mail request' do
      let(:illiad_response_data) { build(:illiad_books_by_mail_request_data) }

      it 'returns true for a books by mail request' do
        expect(request.books_by_mail?).to be true
      end
    end

    context 'with a non books by mail request' do
      it 'returns true for a books by mail request' do
        expect(request.books_by_mail?).to be false
      end
    end
  end

  describe '#scan?' do
    context 'with a request to loan' do
      it 'returns false' do
        expect(request.scan?).to be false
      end
    end

    context 'with a request to scan' do
      let(:illiad_response_data) { build(:illiad_scan_request_data) }

      it 'returns false' do
        expect(request.scan?).to be true
      end
    end
  end
end
