# frozen_string_literal: true

shared_context 'with a successful Library Info request' do |trait = nil, **options|
  before do
    stub_library_info_api_request_success(library_code: code, response_body: api_response)
  end

  let(:api_response) { build :library_info_api_request_response, trait, **options }
end

shared_context 'with a failed Library Info request' do
  before do
    stub_library_info_api_request_failure(library_code: code, response_body: api_response)
  end

  let(:api_response) { { 'message' => 'Invalid libraries_api_key' } }
end
