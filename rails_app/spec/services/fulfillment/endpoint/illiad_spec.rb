# frozen_string_literal: true

describe Fulfillment::Endpoint::Illiad do
  include Illiad::ApiMocks::User
  include Illiad::ApiMocks::Request
  include Alma::ApiMocks::User

  describe '.validate' do
    subject(:errors) { described_class.validate(request: bad_request) }

    context 'when missing patron' do
      let(:bad_request) { build(:fulfillment_request, :with_bib_info, :ill_pickup, requester: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_user_id')
      end
    end

    context 'when patron is a courtesy borrowers' do
      let(:requester) { create(:user, :courtesy_borrower) }
      let(:bad_request) { build(:fulfillment_request, :with_bib_info, :ill_pickup, requester: requester) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_courtesy_borrowers')
      end
    end

    context 'when proxied request is not submitted by a library staff member' do
      include_context 'with mocked alma_record on proxy user'

      let(:bad_request) { build(:fulfillment_request, :with_bib_info, :ill_pickup, proxy_for: proxy.uid) }
      let(:proxy) { Fulfillment::User.new('jdoe') }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_proxy_requests')
      end
    end

    context 'when proxy user is not in Alma' do
      let(:requester) { create(:user, :library_staff) }
      let(:bad_request) { build(:fulfillment_request, :with_bib_info, :ill_pickup, :proxied, requester: requester) }

      before do
        allow(Alma::User).to receive(:find).with('jdoe').and_raise(Alma::User::ResponseError, 'Error retrieving record')
      end

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.proxy_invalid')
      end
    end
  end

  describe '.submit' do
    let(:outcome) { described_class.submit(request: request) }

    before do
      mock_request = instance_double(::Illiad::Request, id: '1234')
      allow(::Illiad::Request).to receive(:submit).and_return(mock_request)
    end

    context 'with a user that already has an Illiad account' do
      before { stub_find_user_success(id: request.requester.uid, response_body: build(:illiad_user_response)) }

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
        let(:note) { I18n.t('fulfillment.illiad.proxy_comment', requester_id: request.requester.uid) }
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
        let(:note) do
          I18n.t('fulfillment.illiad.comment', comment: request.params.comments, user_id: request.requester.uid)
        end
        let(:stub_note_request) do
          stub_add_note_success(id: '1234', note: note, response_body: build(:illiad_api_note_response, Note: note))
        end

        before { stub_note_request }

        it 'adds comment to transaction' do
          expect(outcome).to be_success
          expect(stub_note_request).to have_been_requested
        end
      end

      context 'when requesting a boundwith item' do
        let(:request) { build(:fulfillment_request, :with_section, :with_boundwith, :scan_deliver) }
        let(:note) { I18n.t('fulfillment.illiad.boundwith_comment') }
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

    context 'with a user that does not yet have an Illiad account' do
      let(:username) { request.requester.uid }
      let(:new_user_attributes) do
        described_class::BASE_USER_ATTRIBUTES.merge(
          { Username: username,
            FirstName: request.requester.alma_record.first_name,
            SSN: request.requester.alma_record.id,
            LastName: request.requester.alma_record.last_name,
            EMailAddress: request.requester.email,
            Status: request.requester.ils_group_name,
            Department: request.requester.alma_affiliation,
            PlainTextPassword: Settings.illiad.legacy_user_password }
        )
      end
      let(:request) { build(:fulfillment_request, :with_bib_info, :books_by_mail) }

      before do
        stub_find_user_failure(id: username, response_body: build(:illiad_api_error_response))
        stub_alma_user_find_success(id: username, response_body: build(:alma_user_response, primary_id: username))
        stub_create_user_success(request_body: new_user_attributes,
                                 response_body: build(:illiad_user_response, new_user_attributes))
      end

      it 'succeeds after creating a new Illiad user via the API' do
        expect(outcome).to be_success
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

    context 'with a source param set' do
      let(:source) { Fulfillment::Endpoint::Illiad::ILL_FORM_SOURCE_SID }
      let(:request) do
        build(:fulfillment_request, :with_bib_info, :ill_pickup, source: source)
      end

      it 'sets the CitedIn value properly' do
        expect(submission_body[:CitedIn]).to eq source
      end
    end
  end
end
