# frozen_string_literal: true

shared_context 'with User.new returning user' do
  before do
    allow(User).to receive(:new).and_return(user)
  end
end

# Shared context for mocking an Illiad user on a User object
shared_context 'with mocked illiad_record on user' do
  let(:illiad_user) { create(:illiad_user) }

  before do
    allow(Illiad::User).to receive(:find).with(id: user.uid).and_return(illiad_user)
  end
end
