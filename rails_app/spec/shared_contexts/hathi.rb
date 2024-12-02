# frozen_string_literal: true

# Mock response from Hathi API to return an empty response - Hathi link will not render
shared_context 'with empty hathi response' do
  before { stub_empty_hathi_request }
end

# Mock response from Hathi API to return a present response - Hathi link will render
shared_context 'with present hathi response' do
  before { stub_present_hathi_request(response: JSON.parse(json_fixture('single_id_record', :hathi))) }
end
