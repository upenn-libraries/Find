# frozen_string_literal: true

describe 'Omniauth Callbacks Requests' do
  let(:user) { build(:user) }
  let(:alma_user_group) { { 'value' => 'patron' } }

  include_context 'with User.new returning user'

  context 'with saml authentication' do
    context 'when the user has an Alma account' do
      include_context 'with mock alma_record on user having alma_user_group user group'

      before do
        post user_saml_omniauth_callback_path
      end

      it 'returns success message' do
        follow_redirect!
        expect(response.body).to include(I18n.t('devise.omniauth_callbacks.success', kind: 'saml'))
      end

      it 'creates a user' do
        expect(User.all.count).to eq 1
      end

      it 'sets the user ils_group value' do
        expect(user.ils_group).to eq alma_user_group['value']
      end
    end

    context 'when the user does not have an Alma account' do
      include_context 'with user alma_record lookup returning false'

      before do
        post user_saml_omniauth_callback_path
      end

      it 'returns failure message' do
        follow_redirect!
        expect(response.body).to include(I18n.t('devise.omniauth_callbacks.alma_failure'))
      end

      it 'does not create a user' do
        expect(User.all.count).to eq 0
      end
    end

    context 'when the alma request fails with a user in the database' do
      let(:user) { create(:user) }

      include_context 'with user alma_record lookup returning false'

      before do
        post user_saml_omniauth_callback_path
      end

      it 'does not delete the user' do
        expect(User.all.count).to eq 1
      end
    end

    context 'when the alma request fails without a user in the database' do
      let(:user) { build(:user) }

      include_context 'with user alma_record lookup returning false'

      before do
        post user_saml_omniauth_callback_path
      end

      it 'deletes the user' do
        expect(User.all.count).to eq 0
      end
    end
  end

  context 'with Alma authentication' do
    context 'when authentication succeeds' do
      include_context 'with mock alma_record on user having alma_user_group user group'

      before do
        allow(User).to receive(:authenticated_by_alma?).and_return(true)
        post user_alma_omniauth_callback_path
      end

      it 'returns success message' do
        follow_redirect!
        expect(response.body).to include(I18n.t('devise.omniauth_callbacks.success', kind: 'alma'))
      end

      it 'creates a user' do
        expect(User.all.count).to eq 1
      end

      it 'sets the user ils_group value' do
        expect(user.ils_group).to eq alma_user_group['value']
      end
    end

    context 'when authentication fails' do
      before do
        allow(User).to receive(:authenticated_by_alma?).and_return(false)
        post user_alma_omniauth_callback_path
      end

      it 'returns failure message' do
        follow_redirect!
        expect(response.body).to include(I18n.t('devise.omniauth_callbacks.alma_failure'))
      end

      it 'does not create a user' do
        expect(User.all.count).to eq 0
      end
    end
  end
end
