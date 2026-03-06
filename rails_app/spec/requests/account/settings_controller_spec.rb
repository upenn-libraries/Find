# frozen_string_literal: true

describe 'Account Settings Controller Requests' do
  context 'when not authenticated' do
    it 'redirects to login' do
      get settings_path
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    before do
      allow(user).to receive_messages(alma_record: false, illiad_record: false)
      login_as user
      get settings_path
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
