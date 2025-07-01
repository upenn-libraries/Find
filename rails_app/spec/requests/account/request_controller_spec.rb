# frozen_string_literal: true

describe 'Account Requests requests' do
  before { sign_in user }

  # GET /account/requests/ill/new
  context 'when viewing ILL form' do
    context 'when user is not in an eligible user group to make ILL requests' do
      let(:user) { create(:user, :courtesy_borrower) }

      before do
        sign_in user
        get ill_new_request_path
      end

      it 'redirects to root_path' do
        expect(response).to redirect_to root_url
      end

      it 'displays alert with relevant message' do
        follow_redirect!
        expect(response.body).to include I18n.t('account.ill.restricted_user_html',
                                                ill_guide_url: I18n.t('urls.guides.ill')).html_safe
      end
    end

    context 'when user has an Illiad block and therefore cannot make ILL requests' do
      let(:user) { create(:user) }

      before do
        allow(user).to receive(:ill_blocked?).and_return(true)
        sign_in user
        get ill_new_request_path
      end

      it 'displays alert with relevant message' do
        follow_redirect!
        expect(response.body).to include I18n.t('account.ill.blocked_html',
                                                ill_guide_url: I18n.t('urls.guides.ill')).html_safe
      end
    end
  end
end
