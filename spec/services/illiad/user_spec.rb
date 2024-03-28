# frozen_string_literal: true

describe Illiad::User do
  let(:illiad_user) { build(:illiad_user, data: illiad_response_data) }

  describe '.find' do
    let(:illiad_response_data) { build(:illiad_user_data) }

    context 'with a successful request' do
      include_context 'with stubbed illiad request data'
      it 'returns an Illiad::User' do
        expect(described_class.find(id: illiad_response_data['UserName'])).to be_a described_class
      end
    end

    context 'with an unsuccessful request' do
      include_context 'with stubbed illiad api error'
      it 'raises an error' do
        expect { described_class.find(id: illiad_response_data['UserName']) }.to raise_error(described_class::Error)
      end
    end
  end

  describe '.create' do
    let(:illiad_response_data) { build(:illiad_user_data) }

    context 'with a successful request' do
      include_context 'with stubbed illiad request data'
      it 'returns an Illiad::User' do
        expect(described_class.create(data: illiad_response_data)).to be_a described_class
      end
    end

    context 'with an unsuccessful request' do
      include_context 'with stubbed illiad api error'
      it 'raises an error' do
        expect { described_class.create(data: illiad_response_data) }.to raise_error(described_class::Error)
      end
    end
  end

  describe '.requests' do
    let(:illiad_user) { build(:illiad_user) }
    let(:illiad_response_data) { [build(:illiad_loan_request_data)] }
    let(:requests) { described_class.requests(user_id: illiad_user.id) }

    context 'with a successful request' do
      include_context 'with stubbed illiad request data'

      it 'returns Illiad::RequestSet' do
        expect(requests).to be_a(Illiad::RequestSet)
      end

      it 'returns all loans' do
        amount_of_loans = illiad_response_data.count { |req| req['RequestType'] == Illiad::Request::LOAN }
        expect(requests.loans.size).to eq(amount_of_loans)
      end

      it 'returns all scans' do
        amount_of_scans = illiad_response_data.count { |req| req['RequestType'] == Illiad::Request::ARTICLE }
        expect(requests.scans.size).to eq(amount_of_scans)
      end
    end

    context 'with an unsuccessful request' do
      include_context 'with stubbed illiad api error'

      it 'raises an error' do
        expect { requests }.to raise_error(described_class::Error)
      end
    end
  end

  describe '#id' do
    let(:illiad_response_data) { build(:illiad_user_data) }

    it 'returns expected id' do
      expect(illiad_user.id).to eq illiad_response_data['UserName']
    end
  end

  describe '#requests' do
    let(:illiad_user) { build(:illiad_user) }
    let(:illiad_response_data) { [build(:illiad_loan_request_data), build(:illiad_scan_request_data)] }

    context 'with a successful request' do
      include_context 'with stubbed illiad request data'

      it 'returns Illiad::RequestSet' do
        expect(illiad_user.requests).to be_a(Illiad::RequestSet)
      end

      it 'returns all loans' do
        amount_of_loans = illiad_response_data.count { |req| req['RequestType'] == Illiad::Request::LOAN }
        expect(illiad_user.requests.loans.size).to eq(amount_of_loans)
      end

      it 'returns all scans' do
        amount_of_scans = illiad_response_data.count { |req| req['RequestType'] == Illiad::Request::ARTICLE }
        expect(illiad_user.requests.scans.size).to eq(amount_of_scans)
      end
    end

    context 'with an unsuccessful request' do
      include_context 'with stubbed illiad api error'

      it 'raises an error' do
        expect { illiad_user.requests }.to raise_error(described_class::Error)
      end
    end
  end
end
