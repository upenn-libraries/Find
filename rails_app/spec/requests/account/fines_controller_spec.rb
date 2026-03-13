# frozen_string_literal: true

describe 'Fines Controller Requests' do
  it_behaves_like 'an authenticated controller' do
    let(:path) { fines_and_fees_path }
    let(:user_stubs) { { alma_record: nil } }
  end
end
