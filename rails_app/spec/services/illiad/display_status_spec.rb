# frozen_string_literal: true

describe Illiad::DisplayStatus do
  include Illiad::ApiMocks::DisplayStatus

  let(:display_status) { create(:illiad_display_status) }

  describe '.find_all' do
    let(:statues) { described_class.find_all }

    context 'with a successful request' do
      let(:response_body) { build_list(:illiad_api_display_status_response, 2) }

      before { stub_display_status_find_all_success(response_body: response_body) }

      it 'returns Illiad::DisplayStatusSet' do
        expect(statues).to be_a(Illiad::DisplayStatusSet)
      end
    end

    context 'with an unsuccessful request' do
      let(:response_body) { build(:illiad_api_error_response) }

      before { stub_display_status_find_all_failure(response_body: response_body) }

      it 'raises an error' do
        expect { statues }.to raise_error(Illiad::Client::Error, /#{Illiad::Client::ERROR_MESSAGE}/)
      end
    end
  end

  describe '#transaction_status' do
    it 'returns expected transaction status' do
      expect(display_status.transaction_status).to eql 'Jim MW Processing'
    end
  end

  describe '#display_status' do
    it 'returns expected display status' do
      expect(display_status.display_status).to eql 'In Process'
    end
  end
end
