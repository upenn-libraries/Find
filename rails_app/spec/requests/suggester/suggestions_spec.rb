# frozen_string_literal: true

describe 'Suggestions Requests' do
  context 'with an invalid query' do
    before { get suggester_path(q: ' ') }

    it 'return an error object' do
      expect(response.body).to include(/invalid/)
      expect(response.status).to eq 400
    end
  end

  context 'with valid query' do
    let(:params) { { q: 'query' } }

    before do
      get suggester_path(params, format: :turbo_stream)
    end

    it 'returns a successful response' do
      expect(response.status).to eq 200
    end

    it 'return proper turbo stream headers' do
      expect(response.headers['Content-Type']).to eq 'text/vnd.turbo-stream.html; charset=utf-8'
    end
  end
end
