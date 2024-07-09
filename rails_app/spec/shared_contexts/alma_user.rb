# frozen_string_literal: true

# with a user, return a mock AlmaUser with a stubbed user_group value
shared_context 'with mock alma_record on user having alma_user_group user group' do
  before do
    mock_alma_user = instance_double Alma::User
    allow(mock_alma_user).to receive(:method_missing).with(:user_group).and_return(alma_user_group)
    allow(user).to receive(:alma_record).and_return(mock_alma_user)
  end
end

# with a user, return a mock AlmaUser with stubbed user data, allowing mock AlmaUser to receive explicit and
# meta-programmed instance methods
shared_context 'with mock alma_record on user' do
  before do
    mock_alma_user = instance_double Alma::User
    alma_user_data.each do |field, value|
      if field.in? Alma::User.instance_methods
        allow(mock_alma_user).to receive(field).and_return(value)
      else
        allow(mock_alma_user).to receive(:method_missing).with(field).and_return(value)
      end
    end
    allow(Alma::User).to receive(:find).with(user.uid).and_return(mock_alma_user)
  end
end

shared_context 'with user alma_record lookup returning false' do
  before do
    allow(User).to receive(:new).and_return(user)
    allow(user).to receive(:alma_record).and_return(false)
  end
end

# For a proxy_user, mock an the Alma::User lookup with default ils_group and full_name.
shared_context 'with mocked alma_record on proxy user' do
  let(:proxy_ils_group) { :undergraduate }

  before do
    user_group = { 'value' => proxy_ils_group, 'desc' => proxy_ils_group.to_s.titlecase }
    mock_alma_user = instance_double(Alma::User)
    allow(mock_alma_user).to receive(:method_missing).with(:user_group).and_return(user_group)
    allow(mock_alma_user).to receive(:method_missing).with(:full_name).and_return('John Doe')
    allow(Alma::User).to receive(:find).with(proxy.uid).and_return(mock_alma_user)
  end
end
