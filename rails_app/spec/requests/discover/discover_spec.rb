# frozen_string_literal: true

describe 'Discover Penn Requests' do
  context 'with server side validation' do
    before { get discover_path(q: ' ') }

    it 'displays a message if an empty query term is provided' do
      expect(response.body).to include I18n.t('discover.empty_query')
    end
  end
end
