# frozen_string_literal: true

describe 'Omniauth Callbacks Requests' do
  let(:user) { build(:user) }

  context 'when the user has an Alma account' do
    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(true)

      post user_saml_omniauth_callback_path(uid: 'aalten')
    end

    it 'returns success message' do
      follow_redirect!
      expect(response.body).to include('Successfully authenticated from saml account.')
    end

    it 'creates a user' do
      expect(User.all.count).to eq 1
    end
  end

  context 'when the user does not have an Alma account' do
    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(false)

      post user_saml_omniauth_callback_path(uid: 'aalten')
    end

    it 'returns failure message' do
      follow_redirect!
      expect(response.body).to include('not registered in our library system')
    end

    it 'does not create a user' do
      expect(User.all.count).to eq 0
    end
  end
end
