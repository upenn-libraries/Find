# frozen_string_literal: true

describe 'cataloging errors requests', type: :request do
  let(:user) { create(:user) }

  describe 'POST /cataloging_errors' do
    context 'when not logged it' do
      it 'returns a forbidden' do
        post cataloging_errors_create_path

        expect(response).to redirect_to(login_path)
      end

      it 'does not send a cataloging error report email' do
        expect {
          post cataloging_errors_create_path
        }.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end

    context 'when logged in' do
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

      it 'redirects back to document' do
        post cataloging_errors_create_path, params: params

        expect(response).to have_http_status(:found)
      end
    end
  end
end
