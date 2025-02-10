# frozen_string_literal: true

require 'system_helper'

describe 'Discover Penn page' do
  before do
    visit discover_path(params)
  end

  context 'when no query term is present' do
    let(:params) { nil }

    it 'the search bar has the autofocus attribute' do
      search_bar = find('#q')
      expect(search_bar['autofocus']).to be true
    end
  end

  context 'when a query term is present' do
    let(:params) do
      { q: 'horses' }
    end

    it 'the search bar does not have the autofocus attribute' do
      search_bar = find('#q')
      expect(search_bar['autofocus']).to be_falsey
    end
  end
end
