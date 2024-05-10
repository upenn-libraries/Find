# frozen_string_literal: true

shared_context 'with User.new returning user' do
  before do
    allow(User).to receive(:new).and_return(user)
  end
end
