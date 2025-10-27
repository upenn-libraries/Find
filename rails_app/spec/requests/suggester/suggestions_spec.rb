# frozen_string_literal: true

describe 'Suggestions Requests' do
  let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

  context 'with an invalid query' do
    before { get suggester_path(q: ' ') }

    it 'return an error object' do
      expect(parsed_response[:message]).to include(/invalid/)
      expect(response.status).to eq 400
    end
  end

  context 'with dummy response' do
    before { get suggester_path(q: 'query', count: 5, filtered_param: true) }

    it 'return proper headers' do
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
    end

    it 'returns proper actions' do
      expect(parsed_response.dig(:data, :suggestions, :actions)).to eq(
        [{ label: 'Search titles for "query"', url: 'https://find.library.upenn.edu/?field=title&q=query' }]
      )
    end

    it 'returns proper completions' do
      expect(parsed_response.dig(:data, :suggestions, :completions)).to eq(
        ['query syntax', 'query language', 'query errors', 'adversarial queries']
      )
    end

    it 'returns only allowed context params' do
      expect(parsed_response.dig(:data, :params, :context).keys).to eq [:count]
    end
  end
end
