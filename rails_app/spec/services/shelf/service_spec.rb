# frozen_string_literal: true

describe Shelf::Service do
  include Illiad::ApiMocks::Request

  let(:user_id) { 'test_user' }
  let(:shelf) { described_class.new(user_id) }

  shared_context 'with mocked alma loans request' do
    before do
      loan_set = instance_double(Alma::LoanSet, total_record_count: loans.count)
      allow(Alma::Loan).to receive(:where_user).with(user_id, any_args).and_return(loan_set)
      allow(loan_set).to receive(:map) { |&block| loans.map(&block) }
      allow(loan_set).to receive(:select) { |&block| loans.select(&block) }
    end
  end

  shared_context 'with mocked alma holds request' do
    before do
      request_set = instance_double(Alma::RequestSet, total_record_count: holds.count)
      allow(Alma::UserRequest).to receive(:where_user).with(user_id, any_args).and_return(request_set)
      allow(request_set).to receive(:map) { |&block| holds.map(&block) }
    end
  end

  shared_context 'with mocked illiad transaction requests' do
    let(:display_status_set) { build(:illiad_display_status_set) }
    let(:ill_request_set) { build(:illiad_request_set, requests: ill_requests) }

    before do
      allow(Illiad::DisplayStatus).to receive(:find_all).and_return(display_status_set)
      allow(Illiad::User).to receive(:requests).with(user_id: user_id, filter: anything).and_return(ill_request_set)
    end
  end

  describe '.new' do
    it 'sets user_id' do
      expect(shelf.user_id).to be user_id
    end
  end

  describe '#find_all' do
    include_context 'with mocked alma loans request'
    include_context 'with mocked alma holds request'
    include_context 'with mocked illiad transaction requests'

    let(:loans) { create_list(:alma_loan, 1) }
    let(:holds) { create_list(:alma_hold, 1) }
    let(:ill_requests) { [build(:illiad_api_request_response, :loan)] }

    it 'returns Shelf::Listing' do
      expect(shelf.find_all).to be_a Shelf::Listing
    end

    it 'listing includes loans, holds, and ils transactions' do
      expect(shelf.find_all.map(&:class)).to contain_exactly(
        Shelf::Entry::IlsLoan, Shelf::Entry::IlsHold, Shelf::Entry::IllTransaction
      )
    end
  end

  describe '#find' do
    let(:id) { '123456' }

    it 'calls the appropriate method' do
      allow(shelf).to receive(:ill_transaction)
      shelf.find(:ill, :transaction, id)
      expect(shelf).to have_received(:ill_transaction).with(id)
    end
  end

  describe '#renew_all_loans' do
    include_context 'with mocked alma loans request'

    let(:loans) do
      [build(:alma_loan, :renewable), build(:alma_loan, :renewable), build(:alma_loan, :not_renewable)]
    end

    it 'attempts to renew every renewable loan' do
      allow(shelf).to receive(:renew_loan)
      shelf.renew_all_loans
      expect(shelf).to have_received(:renew_loan).with(loans[0].loan_id)
      expect(shelf).to have_received(:renew_loan).with(loans[1].loan_id)
      expect(shelf).not_to have_received(:renew_loan).with(loans[2].loan_id)
    end
  end

  describe '#renew_loan' do
    let(:loan_id) { '123456' }

    context 'when successful' do
      it 'calls renew_loan' do
        allow(Alma::User).to receive(:renew_loan)
        shelf.renew_loan(loan_id)
        expect(Alma::User).to have_received(:renew_loan).with({ user_id: user_id, loan_id: loan_id })
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::User).to receive(:renew_loan).with({ user_id: user_id, loan_id: loan_id }).and_raise(StandardError)
      end

      it 'raises Shelf::Service::AlmaRequestError' do
        expect { shelf.renew_loan(loan_id) }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end

  describe '#cancel_hold' do
    let(:request_id) { '123456' }

    context 'when successful' do
      it 'calls cancel_request' do
        allow(Alma::User).to receive(:cancel_request)
        shelf.cancel_hold(request_id)
        expect(Alma::User).to have_received(:cancel_request).with({ user_id: user_id, request_id: request_id })
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::User).to receive(:cancel_request).with({ user_id: user_id, request_id: request_id })
                                                     .and_raise(StandardError)
      end

      it 'raises Shelf::Service::AlmaRequestError' do
        expect { shelf.cancel_hold(request_id) }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end

  describe '#delete_scan_transaction' do
    let(:display_status_set) { build(:illiad_display_status_set) }

    before do
      allow(Illiad::DisplayStatus).to receive(:find_all).and_return(display_status_set)
      allow(Illiad::Request).to receive(:find).with(id: ill_transaction.id).and_return(ill_transaction)
    end

    context 'when a loan transaction' do
      let(:ill_transaction) { create(:illiad_request, :loan, Username: user_id) }

      it 'raises error' do
        expect {
          shelf.delete_scan_transaction(ill_transaction.id)
        }.to raise_error Shelf::Service::IlliadRequestError, 'Transaction cannot be deleted'
      end
    end

    context 'when a scan transaction that is not ready for download' do
      let(:ill_transaction) { create(:illiad_request, :scan, Username: user_id) }

      it 'raises error' do
        expect {
          shelf.delete_scan_transaction(ill_transaction.id)
        }.to raise_error Shelf::Service::IlliadRequestError, 'Transaction cannot be deleted'
      end
    end

    context 'when a scan transaction that is ready for download' do
      let(:ill_transaction) { create(:illiad_request, :scan_with_pdf_available, Username: user_id) }

      it 'makes expected request to Illiad API' do
        stub = stub_route_request_success(id: ill_transaction.id, status: 'Request Finished', response_body: '{}')
        shelf.delete_scan_transaction(ill_transaction.id)
        expect(stub).to have_been_requested
      end
    end
  end

  describe '#ils_loans' do
    context 'when successful' do
      include_context 'with mocked alma loans request'

      let(:loans) { create_list(:alma_loan, 1) }

      it 'returns expected objects' do
        expect(shelf.send('ils_loans')).to all(be_an_instance_of(Shelf::Entry::IlsLoan))
      end

      it 'returns expected data' do
        expect(shelf.send('ils_loans').first).to have_attributes(title: loans.first.title, author: loans.first.author)
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::Loan).to receive(:where_user).with(user_id, any_args).and_raise(Alma::LoanSet::ResponseError)
      end

      it 'raises an Shelf::Service::AlmaRequestError' do
        expect { shelf.send('ils_loans') }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end

  describe '#ils_holds' do
    include_context 'with mocked alma holds request'

    let(:holds) { create_list(:alma_hold, 1) }

    context 'when successful' do
      it 'returns expected objects' do
        expect(shelf.send('ils_holds')).to all(be_an_instance_of(Shelf::Entry::IlsHold))
      end

      it 'returns expected data' do
        expect(shelf.send('ils_holds').first).to have_attributes(
          title: holds.first.title,
          author: holds.first.author,
          pickup_location: holds.first.pickup_location
        )
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::UserRequest).to receive(:where_user).with(user_id, any_args)
                                                        .and_raise(Alma::RequestSet::ResponseError)
      end

      it 'raises an Shelf::Service::AlmaRequestError' do
        expect { shelf.send('ils_holds') }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end

  describe '#ill_transactions' do
    include_context 'with mocked illiad transaction requests'
    let(:ill_requests) { [build(:illiad_api_request_response, :loan)] }

    context 'when successful' do
      it 'returns expected objects' do
        expect(shelf.send('ill_transactions')).to all(be_an_instance_of(Shelf::Entry::IllTransaction))
      end

      it 'returns expected data' do
        expect(shelf.send('ill_transactions').first).to have_attributes(
          title: ill_requests.first[:LoanTitle],
          author: ill_requests.first[:LoanAuthor]
        )
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Illiad::User).to receive(:requests).with(user_id: user_id, filter: anything)
                                                 .and_raise(Illiad::Client::Error)
      end

      it 'raises an Shelf::Service::IlliadRequestError' do
        expect { shelf.send('ill_transactions') }.to raise_error(Shelf::Service::IlliadRequestError)
      end
    end
  end

  describe '#ill_transaction' do
    let(:display_status_set) { build(:illiad_display_status_set) }
    let(:ill_transaction) { create(:illiad_request, :loan, Username: user_id) }

    context 'when successful' do
      before do
        allow(Illiad::DisplayStatus).to receive(:find_all).and_return(display_status_set)
        allow(Illiad::Request).to receive(:find).with(id: ill_transaction.id).and_return(ill_transaction)
      end

      it 'returns Shelf::Entry::IllTransaction' do
        expect(shelf.send(:ill_transaction, ill_transaction.id)).to be_a Shelf::Entry::IllTransaction
      end

      it 'contains expected data' do
        expect(shelf.send(:ill_transaction, ill_transaction.id)).to have_attributes(
          title: ill_transaction.data[:LoanTitle],
          author: ill_transaction.data[:LoanAuthor]
        )
      end
    end

    context 'when transaction does not belong to user' do
      let(:ill_transaction) { create(:illiad_request) }

      before do
        allow(Illiad::Request).to receive(:find).with(id: ill_transaction.id).and_return(ill_transaction)
      end

      it 'raises an error' do
        expect {
          shelf.send(:ill_transaction, ill_transaction.id)
        }.to raise_error(Shelf::Service::IlliadRequestError, 'Transaction does not belong to user.')
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Illiad::Request).to receive(:find).with(id: ill_transaction.id).and_raise(Illiad::Client::Error)
      end

      it 'raises an Shelf::Service::IlliadRequestError' do
        expect { shelf.send(:ill_transaction, ill_transaction.id) }.to raise_error(Shelf::Service::IlliadRequestError)
      end
    end
  end

  describe '#ils_loan' do
    let(:loan) { create(:alma_loan) }

    context 'when successful' do
      before do
        allow(Alma::User).to receive(:find_loan).with({ user_id: user_id, loan_id: loan.loan_id }).and_return(loan)
      end

      it 'returns Shelf::Entry::IlsLoan' do
        expect(shelf.send(:ils_loan, loan.loan_id)).to be_a Shelf::Entry::IlsLoan
      end

      it 'contains expected data' do
        expect(shelf.send(:ils_loan, loan.loan_id)).to have_attributes(title: loan.title, author: loan.author)
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::User).to receive(:find_loan).with({ user_id: user_id, loan_id: loan.loan_id })
                                                .and_raise(Alma::StandardError)
      end

      it 'raises an Shelf::Service::AlmaRequestError' do
        expect { shelf.send(:ils_loan, loan.loan_id) }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end

  describe '#ils_hold' do
    let(:hold) { create(:alma_hold) }

    context 'when successful' do
      before do
        allow(Alma::User).to receive(:find_request).with({ user_id: user_id, request_id: hold.request_id })
                                                   .and_return(hold)
      end

      it 'returns Shelf::Entry::IlHold' do
        expect(shelf.send(:ils_hold, hold.request_id)).to be_a Shelf::Entry::IlsHold
      end

      it 'contains expected data' do
        expect(shelf.send(:ils_hold, hold.request_id)).to have_attributes(title: hold.title, author: hold.author)
      end
    end

    context 'when unsuccessful' do
      before do
        allow(Alma::User).to receive(:find_request).with({ user_id: user_id, request_id: hold.request_id })
                                                   .and_raise(StandardError)
      end

      it 'raises an Shelf::Service::AlmaRequestError' do
        expect { shelf.send(:ils_hold, hold.request_id) }.to raise_error(Shelf::Service::AlmaRequestError)
      end
    end
  end
end
