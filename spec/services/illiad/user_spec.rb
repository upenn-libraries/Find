# frozen_string_literal: true

describe Illiad::User do
  include Illiad::ApiMocks::User

  let(:illiad_user) { build(:illiad_user) }

  describe '.find' do
    context 'with a successful request' do
      before { stub_find_user_success(id: illiad_user.id, response_body: FactoryBot.json(:illiad_user_response)) }

      it 'returns an Illiad::User' do
        expect(described_class.find(id: illiad_user.id)).to be_a described_class
      end
    end

    context 'with an unsuccessful request' do
      before { stub_find_user_failure(id: illiad_user.id, response_body: FactoryBot.json(:illiad_api_error_response)) }

      it 'raises an error' do
        expect { described_class.find(id: illiad_user.id) }
          .to raise_error(described_class::Error, /#{Illiad::Connection::ERROR_MESSAGE}/)
      end
    end
  end

  describe '.create' do
    let(:username) { 'new user' }
    let(:request_body) { attributes_for(:illiad_user, UserName: username) }

    context 'with a successful request' do
      let(:response_body) { json(:illiad_user_response, UserName: username) }

      before { stub_create_user_success(request_body: request_body, response_body: response_body) }

      it 'returns an Illiad::User' do
        expect(described_class.create(data: request_body)).to be_a described_class
      end
    end

    context 'with an unsuccessful request' do
      let(:response_body) { json(:illiad_api_error_response, :with_model_error) }

      before { stub_create_user_failure(request_body: request_body, response_body: response_body) }

      it 'raises an error' do
        expect { described_class.create(data: request_body) }
          .to raise_error(described_class::Error, /#{Illiad::Connection::ERROR_MESSAGE}/)
      end
    end
  end

  describe '.requests' do
    let(:requests) { described_class.requests(user_id: illiad_user.id) }

    context 'with a successful request' do
      let(:response_body) { build_list(:illiad_api_request_response, 2, :loan).to_json }

      before { stub_user_requests_success(user_id: illiad_user.id, response_body: response_body) }

      it 'returns Illiad::RequestSet' do
        expect(requests).to be_a(Illiad::RequestSet)
      end
    end

    context 'with an unsuccessful request' do
      let(:response_body) { json(:illiad_api_error_response) }

      before { stub_user_requests_failure(user_id: illiad_user.id, response_body: response_body) }

      it 'raises an error' do
        expect { requests }.to raise_error(described_class::Error, /#{Illiad::Connection::ERROR_MESSAGE}/)
      end
    end
  end

  describe '#id' do
    let(:id) { 'new user' }
    let(:illiad_user) { build(:illiad_user, UserName: id) }

    it 'returns expected id' do
      expect(illiad_user.id).to eq id
    end
  end
end
