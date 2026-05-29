# frozen_string_literal: true

describe 'Account Controller Requests' do
  context 'when not authenticated' do
    it 'responds successfully' do
      get account_path
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    before do
      login_as user
      get account_path
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
