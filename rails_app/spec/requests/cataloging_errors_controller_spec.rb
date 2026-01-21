# frozen_string_literal: true

describe 'cataloging errors requests', type: :request do
  let(:user) { create(:user) }

  describe 'GET /cataloging_errors/new' do
    context 'when not signed in' do
      it 'redirects to sign-in' do
        get cataloging_errors_new_path(mms_id: '123456')

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in' do
      before { login_as user }

      it 'returns a successful response' do
        get cataloging_errors_new_path(mms_id: '123456')

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /cataloging_errors' do
    before { login_as user }

    let(:params) do
      {
        user: user.id,
        mms_id: '123456',
        message: 'The publication date is incorrect.'
      }
    end

    it 'sends a cataloging error report email' do
      expect {
        post cataloging_errors_create_path, params: params
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'redirects back with a success message' do
      post cataloging_errors_create_path, params: params

      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq(
        I18n.t('cataloging_errors.success')
      )
    end
  end
end
