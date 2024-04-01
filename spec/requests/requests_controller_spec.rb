# frozen_string_literal: true

describe 'Requests Requests' do
  let(:mms_id) { '1234' }
  let(:holding_id) { '5678' }

  # /requests/new
  context 'when viewing the new page' do
    context 'with an unauthorized user' do
      it 'redirects to root' do
        get new_request_path(mms_id: mms_id, holding_id: holding_id)
        expect(response).to redirect_to root_path
        expect(flash['alert']).to include 'You need to sign in'
      end
    end
  end
end
