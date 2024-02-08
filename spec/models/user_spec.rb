# frozen_string_literal: true

describe User do
  describe '.from-omniauth-saml' do
    let(:auth_info) do
      OmniAuth::AuthHash.new(
        { provider: user.provider, info: OmniAuth::AuthHash::InfoHash.new(
          { uid: "#{user.uid}@upenn.edu" }
        ) }
      )
    end

    context 'when the user already exists' do
      let(:user) { create(:user) }

      it 'finds and returns the user' do
        returned_user = described_class.from_omniauth_saml(auth_info)
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end

    context 'when the user does not exist' do
      let(:user) { build(:user) }

      it 'creates and returns the user' do
        returned_user = described_class.from_omniauth_saml(auth_info)
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end
  end

  describe '.from_omniauth_alma' do
    let(:auth_info) do
      OmniAuth::AuthHash.new(
        { provider: user.provider, info: OmniAuth::AuthHash::InfoHash.new(
          { uid: user.uid }
        ) }
      )
    end

    let(:returned_user) { described_class.from_omniauth_alma(auth_info) }

    context 'when the user already exists' do
      let(:user) { create(:user, :courtesy_borrower) }

      it 'finds and returns the user' do
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end

    context 'when the user does not exist' do
      let(:user) { build(:user, :courtesy_borrower) }

      it 'creates and returns the user' do
        expect(returned_user.uid).to eq user.uid
        expect(returned_user.email).to eq user.email
      end
    end
  end

  describe '.authenticated_by_alma?' do
    context 'when an error is raised' do
      before do
        allow(Alma::User).to receive(:authenticate).and_raise(ArgumentError)
      end

      it 'returns false' do
        expect(described_class.authenticated_by_alma?({})).to be false
      end
    end
  end
end
