# frozen_string_literal: true

describe 'Fines Controller Requests' do
  context 'when not authenticated' do
    it 'redirects to login' do
      get fines_and_fees_path
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    before do
      allow(user).to receive(:alma_record).and_return(nil)
      login_as user
      get fines_and_fees_path
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
