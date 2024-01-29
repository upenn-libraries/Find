# frozen_string_literal: true

describe User do
  describe '.from-omniauth-saml' do
    context 'when the user already exists' do
      let(:user) { create(:user) }
      let(:auth_info) do
        OmniAuth::AuthHash.new(
          { provider: user.provider, info: OmniAuth::AuthHash::InfoHash.new(
            { uid: "#{user.uid}@upenn.edu" }
          ) }
        )
      end

      it 'finds and returns the user' do
        returned_user = described_class.from_omniauth_saml(auth_info)
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end

    context 'when the user does not exist' do
      let(:user) { build(:user) }
      let(:auth_info) do
        OmniAuth::AuthHash.new(
          { provider: user.provider, info: OmniAuth::AuthHash::InfoHash.new(
            { uid: "#{user.uid}@upenn.edu" }
          ) }
        )
      end

      it 'creates and returns the user' do
        returned_user = described_class.from_omniauth_saml(auth_info)
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end
  end
end
