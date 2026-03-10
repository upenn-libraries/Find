# frozen_string_literal: true

RSpec.shared_examples 'an authenticated controller' do
  let(:user_stubs) { {} }

  context 'when not authenticated' do
    it 'redirects to login' do
      get path
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    before do
      allow(user).to receive_messages(user_stubs) if user_stubs.any?
      login_as user
      get path
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
