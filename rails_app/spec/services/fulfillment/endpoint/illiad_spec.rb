# frozen_string_literal: true

describe Fulfillment::Endpoint::Illiad do
  include Illiad::ApiMocks::User
  include Illiad::ApiMocks::Request

  describe '.validate' do
    let(:bad_request) { build(:fulfillment_request, :with_bib_info, :pickup, requester: nil) }

    it 'adds error messages to errors' do
      expect(described_class.validate(request: bad_request)).to match_array ['No user identifier provided']
    end
  end

  describe '.submit' do
    let(:outcome) { described_class.submit(request: request) }

    before do
      stub_find_user_success(id: request.requester.uid, response_body: build(:illiad_user_response))
      mock_request = instance_double(::Illiad::Request, id: '1234')
      allow(::Illiad::Request).to receive(:submit).and_return(mock_request)
    end

    context 'with a successful BBM delivery request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :books_by_mail) }

      it 'returns an outcome with the confirmation number' do
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ILLIAD_1234'
      end
    end

    context 'with a successful ScanDeliver request' do
      let(:request) { build(:fulfillment_request, :with_section, :scan_deliver) }

      it 'returns an outcome with the confirmation number' do
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ILLIAD_1234'
      end
    end

    context 'with a successful Bib request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :ill_pickup) }

      it 'returns an outcome with with the confirmation number' do
        expect(outcome).to be_success
        expect(outcome.confirmation_number).to eq 'ILLIAD_1234'
      end
    end

    context 'with a successful proxied request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :proxied, :ill_pickup) }
      let(:note) { "Proxied by #{request.requester.uid}" }
      let(:stub_note_request) do
        stub_add_note_success(id: '1234', note: note, response_body: build(:illiad_api_note_response, Note: note))
      end

      before do
        stub_note_request
        stub_find_user_success(id: request.patron.uid, response_body: build(:illiad_user_response))
      end

      it 'submits request as proxied user' do
        outcome
        expect(::Illiad::Request).to have_received(:submit).with(data: a_hash_including(Username: 'jdoe'))
      end

      it 'adds note to transaction' do
        expect(outcome).to be_success
        expect(stub_note_request).to have_been_requested
      end
    end

    context 'with a request containing a comment' do
      let(:request) { build(:fulfillment_request, :with_section, :with_comments, :scan_deliver) }
      let(:note) { "#{request.params.comments} - comment submitted by #{request.requester.uid}" }
      let(:stub_note_request) do
        stub_add_note_success(id: '1234', note: note, response_body: build(:illiad_api_note_response, Note: note))
      end

      before { stub_note_request }

      it 'adds comment to transaction' do
        expect(outcome).to be_success
        expect(stub_note_request).to have_been_requested
      end
    end
  end

  describe '.submission_body_from' do
    let(:submission_body) { described_class.send(:submission_body_from, request) }

    context 'with a books by mail request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :books_by_mail) }

      it 'properly appends the needed info in the submission body' do
        expect(submission_body[:ItemInfo1]).to eq Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL
        expect(submission_body[:LoanTitle]).to match(/^BBM/)
      end
    end

    context 'with a Faculty Express request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :office_delivery) }

      it 'properly appends the needed info in the submission body' do
        expect(submission_body[:ItemInfo1]).to eq Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL
      end
    end

    context 'with a pickup request' do
      let(:request) { build(:fulfillment_request, :with_bib_info, :ill_pickup) }

      it 'properly sets the pickup location' do
        expect(submission_body[:ItemInfo1]).to eq request.pickup_location
      end

      it 'does not append any books by mail params' do
        expect(submission_body[:LoanTitle]).to eql request.params.title
      end
    end
  end
end
