# frozen_string_literal: true

describe Fulfillment::User do
  include Alma::ApiMocks::User

  let(:uid) { 'test' }

  it_behaves_like 'Illiad Account' do
    let(:object) { described_class.new(uid) }
  end

  describe '#email' do
    let(:email) { "#{uid}@upenn.edu" }

    before do
      stub_alma_user_find_success(id: uid, response_body: {
                                    'contact_info' => { 'email' => [{ 'email_address' => email,
                                                                      'preferred' => true }] }
                                  })
    end

    it 'has an email' do
      expect(described_class.new(uid).email).to eq email
    end
  end
end
