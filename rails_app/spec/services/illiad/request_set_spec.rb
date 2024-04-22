# frozen_string_literal: true

describe Illiad::RequestSet do
  let(:requests) do
    [build(:illiad_api_request_response, :loan),
     build(:illiad_api_request_response, :books_by_mail),
     build(:illiad_api_request_response, :scan)]
  end
  let(:request_set) { build(:illiad_request_set, requests: requests) }

  describe '#requests' do
    it 'creates Illiad:Request instances' do
      expect(request_set.all? { |req| req.is_a?(Illiad::Request) }).to be true
    end
  end

  describe '#loans' do
    it 'returns only loan requests' do
      expect(request_set.loans.all?(&:loan?)).to be true
    end
  end

  describe '#books_by_mail' do
    it 'returns only books by mail requests' do
      expect(request_set.books_by_mail.all?(&:books_by_mail?)).to be true
    end
  end

  describe '#scans' do
    it 'returns only scans' do
      expect(request_set.scans.all?(&:scan?)).to be true
    end
  end
end
