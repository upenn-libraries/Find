# frozen_string_literal: true

describe 'Suggestions Requests' do
  context 'with dummy response' do
    before { get suggester_path(q: 'query', count: 5, filtered_param: true) }

    let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

    it 'return proper headers' do
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
    end

    it 'returns only allowed context params' do
      expect(parsed_response.dig(:data, :params, :context).keys).to eq [:count]
    end
  end
end
