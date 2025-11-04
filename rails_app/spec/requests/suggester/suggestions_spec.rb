# frozen_string_literal: true

describe 'Suggestions Requests' do
  include Suggester::SpecHelpers

  let(:parsed_response) { Nokogiri::HTML(response.body) }

  context 'with an exception raised by the suggester service' do
    before do
      allow(Suggester::Service).to receive(:call).and_raise(StandardError)
      get suggester_path('query', format: :turbo_stream)
    end

    it 'returns an listbox element for consistent UX' do
      expect(parsed_response.css('#suggestions-listbox')).to be_present
      expect(response.status).to eq 500
    end
  end

  context 'with valid query' do
    before do
      allow(Suggester::Service).to receive(:call).and_return(suggester_response)
      get suggester_path('query', format: :turbo_stream)
    end

    it 'returns a successful response' do
      expect(response.status).to eq 200
    end

    it 'return turbo stream media type' do
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end

  context 'with actions returned' do
    let(:mock_suggester_response) { suggester_response(actions: [{ label: 'Test', url: 'https://test.com' }]) }

    before do
      allow(Suggester::Service).to receive(:call).and_return(mock_suggester_response)
      get suggester_path('query', format: :turbo_stream)
    end

    it 'return proper action elements' do
      li_elements = parsed_response.css('li')
      expect(li_elements.size).to eq 1
      expect(li_elements.first.attributes).to include('data-pl-value', 'data-action-url')
    end
  end

  context 'with completions returned' do
    let(:mock_suggester_response) { suggester_response(completions: ['query language']) }

    before do
      allow(Suggester::Service).to receive(:call).and_return(mock_suggester_response)
      get suggester_path('query', format: :turbo_stream)
    end

    it 'return proper suggestion elements' do
      li_elements = parsed_response.css('li')
      expect(li_elements.size).to eq 1
      expect(li_elements.first['role']).to eq 'option'
    end
  end
end
