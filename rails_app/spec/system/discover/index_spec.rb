# frozen_string_literal: true

require 'system_helper'

describe 'Discover Penn page' do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  before do
    stub_all_responses(query: query)
    visit discover_path
    fill_in 'q', with: query[:q]
    click_on I18n.t('discover.search.button.label')
  end

  context 'when not returning results' do
    before do
      visit discover_path
      fill_in 'q', with: query[:q]
      click_on I18n.t('discover.search.button.label')
    end

    context 'with no query term provided' do
      let(:query) { { q: '' } }

      it 'shows an HTML5 validation message that a query term is required' do
        expect(page).to have_field 'q', validation_message: 'Please fill out this field.'
      end
    end

    context 'with an invalid query term provided' do
      let(:query) { { q: '   ' } }

      it 'shows an HTML5 validation message' do
        expect(page).to have_field 'q', validation_message: /Please match the requested format/
      end
    end
  end

  context 'when returning results' do
    before do
      stub_all_responses(query: query)
      visit discover_path
      fill_in 'q', with: query[:q]
      click_on I18n.t('discover.search.button.label')
    end

    let(:query) { { q: 'test' } }

    # These tests confirm that the proper areas are updated by the turbo streams rendered by ResultsComponent
    context 'with libraries results' do
      it 'displays the expected icon' do
        within('#libraries') { expect(page).to have_css('i.bi.bi-book') }
      end

      it 'displays the total count in the overview area' do
        expect(page).to have_selector '#libraries-results-count.results-count', text: '(1)'
      end
    end
  end
end
