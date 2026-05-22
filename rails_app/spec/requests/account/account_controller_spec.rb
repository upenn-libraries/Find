# frozen_string_literal: true

describe 'Account Controller Requests' do
  it_behaves_like 'an authenticated controller' do
    let(:path) { account_path }
  end
end
