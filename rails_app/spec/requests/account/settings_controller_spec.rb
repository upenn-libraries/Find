# frozen_string_literal: true

describe 'Account Settings Controller Requests' do
  it_behaves_like 'an authenticated controller' do
    let(:path) { settings_path }
    let(:user_stubs) { { alma_record: false, illiad_record: false } }
  end
end
