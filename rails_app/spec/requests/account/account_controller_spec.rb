# frozen_string_literal: true

describe 'Account Controller Requests' do
  context 'when not authenticated' do
    it 'redirects to login' do
      get account_path
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when authenticated' do
    before do
      login_as create(:user)
      get account_path
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
