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

  context 'with valid query' do
    let(:engines) { [Suggester::Engines::TitleSearch, Suggester::Engines::TitleCompletion] }
    let(:params) { { q: 'query', filtered_param: true } }

    before do
      allow(Suggester::EngineRegistry).to receive(:registry).and_return engines
      get suggester_path(params)
    end

    it 'return proper headers' do
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
    end

    it 'returns proper actions' do
      expect(parsed_response.dig(:data, :suggestions, :actions)).to eq(
        [{ label: "Search 'query' in titles.",
           url: 'https://find.library.upenn.edu?q=query&search_field=title_search' }]
      )
    end

    it 'returns proper completions' do
      expect(parsed_response.dig(:data, :suggestions,
                                 :completions)).to eq(['Title containing <b>query</b>',
                                                       'Another title containing <b>query</b>'])
    end

    it 'returns only allowed context params' do
      expect(parsed_response.dig(:data, :params,
                                 :context).keys).to contain_exactly(:actions_limit, :completions_limit)
    end

    context 'with limit parameters' do
      let(:params) { { q: 'query', actions_limit: 0, completions_limit: 1 } }

      it 'returns limited actions' do
        expect(parsed_response.dig(:data, :suggestions, :actions)).to eq []
      end

      it 'returns limited completions' do
        expect(parsed_response.dig(:data, :suggestions, :completions)).to eq(['Title containing <b>query</b>'])
      end
    end
  end
end
