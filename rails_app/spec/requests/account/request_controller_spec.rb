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
end
