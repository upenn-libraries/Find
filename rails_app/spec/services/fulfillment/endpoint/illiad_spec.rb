# frozen_string_literal: true

describe Fulfillment::Endpoint::Illiad do
  include Illiad::ApiMocks::User
  include Illiad::ApiMocks::Request

  describe '.validate' do
    let(:bad_request) { build(:fulfillment_request, :with_bib, :pickup, user: nil) }

    it 'adds error messages to errors' do
      expect(described_class.validate(request: bad_request)).to match_array ['No user identifier provided']
    end
  end

  describe '.submit' do
    context 'with a successful BBM delivery request' do
      let(:bbm_request) { build(:fulfillment_request, :with_bib, :books_by_mail) }
      let(:response_hash) { { 'a' => 'b' } }
      let(:note) { " - comment submitted by #{bbm_request.user.uid}" }

      before do
        stub_find_user_success(id: bbm_request.user.uid, response_body: build(:illiad_user_response))
        stub_add_note_success(id: '1234', note: note,
                              response_body: build(:illiad_api_note_response, Note: note))
        mock_request = instance_double(::Illiad::Request)
        allow(mock_request).to receive(:id).and_return '1234'
        allow(::Illiad::Request).to receive(:submit).and_return(mock_request)
      end

      it 'returns an outcome with with the confirmation number' do
        outcome = described_class.submit(request: bbm_request)
        expect(outcome).to be_success
        # TODO: check body for BBM values
        expect(outcome.confirmation_number).to eq 'ILLIAD_1234'
      end
    end

    context 'with a successful ScanDeliver request' do
      let(:scan_request) { build(:fulfillment_request, :with_section, :scan_deliver) }
      let(:response_hash) { { 'a' => 'b' } }
      let(:note) { " - comment submitted by #{scan_request.user.uid}" }

      before do
        stub_find_user_success(id: scan_request.user.uid, response_body: build(:illiad_user_response))
        stub_add_note_success(id: '1234', note: note,
                              response_body: build(:illiad_api_note_response, Note: note))
        mock_request = instance_double(::Illiad::Request)
        allow(mock_request).to receive(:id).and_return '1234'
        allow(::Illiad::Request).to receive(:submit).and_return(mock_request)
      end

      it 'returns an outcome with with the confirmation number' do
        outcome = described_class.submit(request: scan_request)
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ILLIAD_1234'
      end
    end
  end
end
