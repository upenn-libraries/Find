# frozen_string_literal: true

describe 'Account Requests requests' do
  let(:user) { create(:user) }

  before { sign_in user }

  # GET /account/requests/ill/new
  context 'when viewing ill form' do
    before { get ill_new_request_path }

    context 'when user is a courtesy borrower' do
      let(:user) { create(:user, :courtesy_borrower) }

      it 'redirects to root_path' do
        expect(response).to redirect_to root_url
      end

      it 'displays alert message' do
        follow_redirect!
        expect(response.body).to include I18n.t('fulfillment.validation.no_courtesy_borrowers')
      end
    end
  end

  context 'when renewing all loans' do
    before do
      shelf_service = instance_double Shelf::Service
      renewal_response = instance_double Alma::RenewalResponse
      allow(renewal_response).to receive(:message).and_return('This item is now due later.')
      allow(renewal_response).to receive(:renewed?).and_return(true)
      allow(Shelf::Service).to receive(:new).with(user.uid).and_return(shelf_service)
      allow(shelf_service).to receive(:renew_all_loans).and_return(Array.new(50) { renewal_response })
      patch ils_renew_all_request_url
    end

    context 'when the content is too big for flash storage' do
      it 'displays a short message' do
        follow_redirect!
        expect(response.body).to include 'See below for the new due dates for your loans.'
      end
    end
  end
end
