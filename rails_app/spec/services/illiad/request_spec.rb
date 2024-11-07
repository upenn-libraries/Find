# frozen_string_literal: true

describe Illiad::Request do
  include Illiad::ApiMocks::Request

  let(:request) { build(:illiad_request, :loan) }

  describe '.submit' do
    let(:request_body) { { UserName: 'testuser', RequestType: 'Borrowing' } }
    let(:response_body) { build(:illiad_api_request_response, :loan) }

    context 'with a successful api request' do
      before { stub_submit_request_success(request_body: request_body, response_body: response_body) }

      it 'returns an Illiad::Request instance' do
        expect(described_class.submit(data: request_body)).to be_a(described_class)
      end
    end

    context 'with an unsuccessful api request' do
      let(:response_body) { build(:illiad_api_error_response, :with_model_error) }

      before { stub_submit_request_failure(request_body: request_body, response_body: response_body) }

      it 'raises an error' do
        expect { described_class.submit(data: request_body) }
          .to raise_error(Illiad::Client::Error, /#{Illiad::Client::ERROR_MESSAGE}/)
      end
    end
  end

  describe '.find' do
    context 'with a successful api request' do
      let(:response_body) { build(:illiad_api_request_response, :loan) }

      before { stub_find_request_success(id: request.id, response_body: response_body) }

      it 'returns an Illiad::Request instance' do
        expect(described_class.find(id: request.id)).to be_a(described_class)
      end
    end

    context 'with an unsuccessful api request' do
      let(:response_body) { build(:illiad_api_error_response) }

      before { stub_find_request_failure(id: request.id, response_body: response_body) }

      it 'raises an error ' do
        expect { described_class.find(id: request.id) }
          .to raise_error(Illiad::Client::Error, /#{Illiad::Client::ERROR_MESSAGE}/)
      end
    end
  end

  describe '.add_note' do
    context 'with a successful api request' do
      let(:note) { 'test note' }
      let(:response_body) { build(:illiad_api_note_response, Note: note) }

      before { stub_add_note_success(id: request.id, note: note, response_body: response_body) }

      it 'returns the illiad note data' do
        expect(described_class.add_note(id: request.id, note: note)).to eq response_body
      end
    end

    context 'with an unsuccessful api request' do
      let(:note) { 'test note' }
      let(:response_body) { build(:illiad_api_error_response, :with_model_error) }

      before { stub_add_note_failure(id: request.id, note: note, response_body: response_body) }

      it 'raises an error ' do
        expect { described_class.add_note(id: request.id, note: note) }
          .to raise_error(Illiad::Client::Error, /#{Illiad::Client::ERROR_MESSAGE}/)
      end
    end
  end

  describe '.route' do
    context 'with a successful api request' do
      let(:status) { 'Request Finished' }
      let(:response_body) { build(:illiad_api_route_request_response, TransactionStatus: status) }

      before { stub_route_request_success(id: request.id, status: status, response_body: response_body) }

      it 'returns an Illiad::Request instance with updated status' do
        response = described_class.route(id: request.id, status: status)
        expect(response).to be_a(described_class)
        expect(response.status).to eq status
      end
    end

    context 'with an unsuccessful api request' do
      let(:status) { 'Request Finished' }
      let(:response_body) { build(:illiad_api_error_response) }

      before { stub_route_request_failure(id: request.id, status: status, response_body: response_body) }

      it 'raises an error ' do
        expect { described_class.route(id: request.id, status: status) }
          .to raise_error(Illiad::Client::Error, /#{Illiad::Client::ERROR_MESSAGE}/)
      end
    end
  end

  describe '#request_type' do
    it 'returns expected request type' do
      expect(request.request_type).to eq Illiad::Request::LOAN
    end
  end

  describe '#status' do
    let(:status) { 'test status' }
    let(:request) { build(:illiad_request, :loan, TransactionStatus: status) }

    it 'returns expected status' do
      expect(request.status).to eq status
    end
  end

  describe '#date' do
    let(:date) { DateTime.now.to_s }
    let(:request) { build(:illiad_request, :loan, TransactionDate: date) }

    it 'returns expected transaction date' do
      expect(request.date).to eq DateTime.parse(date)
    end
  end

  describe '#due_date' do
    let(:due_date) { DateTime.now.to_s }
    let(:request) { build(:illiad_request, :loan, DueDate: due_date) }

    it 'returns due date' do
      expect(request.due_date).to eq DateTime.parse(due_date)
    end
  end

  describe '#loan?' do
    context 'with request to loan' do
      it 'returns true' do
        expect(request.loan?).to be true
      end
    end

    context 'with a request to scan and no web delivery status' do
      let(:request) { build(:illiad_request, :scan) }

      it 'returns false' do
        expect(request.loan?).to be false
      end
    end

    context 'with a request to scan but with web delivery status' do
      let(:request) { build(:illiad_request, :article_with_pdf_available) }

      it 'returns false' do
        expect(request.loan?).to be false
      end
    end
  end

  describe '#books_by_mail?' do
    context 'with a books by mail request' do
      let(:request) { build(:illiad_request, :books_by_mail) }

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

    context 'with a request to loan and web delivery status' do
      let(:request) { build(:illiad_request, :article_with_pdf_available) }

      it 'returns true' do
        expect(request.scan?).to be true
      end
    end

    context 'with a request to scan' do
      let(:request) { build(:illiad_request, :scan) }

      it 'returns false' do
        expect(request.scan?).to be true
      end
    end
  end
end
