# frozen_string_literal: true

# with a user, return a mock AlmaUser with a stubbed user_group value
shared_context 'with mock alma_record on user having alma_user_group user group' do
  before do
    mock_alma_user = instance_double Alma::User
    allow(mock_alma_user).to receive(:method_missing).with(:user_group).and_return({ 'value' => alma_user_group })
    allow(user).to receive(:alma_record).and_return(mock_alma_user)
  end
end

shared_context 'with user alma_record lookup returning false' do
  before do
    allow(User).to receive(:new).and_return(user)
    allow(user).to receive(:alma_record).and_return(false)
  end
end
