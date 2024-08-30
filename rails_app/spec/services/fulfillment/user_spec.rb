# frozen_string_literal: true

describe Fulfillment::User do
  include Alma::ApiMocks::User

  let(:uid) { 'test' }
  let(:object) { described_class.new(uid) }

  it_behaves_like 'Illiad Account'

  describe '#email' do
    let(:email) { "#{uid}@upenn.edu" }

    before do
      stub_alma_user_find_success(id: uid, response_body: {
                                    'contact_info' => { 'email' => [{ 'email_address' => email,
                                                                      'preferred' => true }] }
                                  })
    end

    it 'returns the expected value' do
      expect(object.email).to eq email
    end
  end
end
