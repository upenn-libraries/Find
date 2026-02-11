# frozen_string_literal: true

describe Discover::ResultsComponent, type: :components do
  let(:component) { described_class.new(results: results, source: source, count: count) }
  let(:rendered) { render_inline(component) }
  let(:source) { Discover::Configuration::SOURCES.first }

  context 'with no count parameter specified' do
    let(:count) { Discover::Configuration::RESULT_MAX_COUNT }
    let(:results) do
      Discover::Results.new(entries: build_pair(:discover_record),
                            source: source, total_count: 2, results_url: 'https://www.results.com')
    end

    it 'renders the results' do
      expect(rendered).to have_selector '.results-list-item', count: 2
    end

    it 'renders a link to all results' do
      within('turbo-frame') do
        expect(rendered).to have_selector(
          "#libraries-results-button a[href='#{results.results_url}']",
          text: I18n.t('discover.results.view_all_button.label', count: results.total_count)
        )
      end
    end
  end

  context 'with a count parameter specified' do
    let(:count) { 1 }
    let(:results) do
      Discover::Results.new(entries: build_pair(:discover_record),
                            source: source, total_count: 2, results_url: nil)
    end

    it 'applies a limit to the displayed results' do
      expect(rendered).to have_selector '.results-list-item', count: 1
    end
  end

  context 'with no results' do
    let(:count) { Discover::Configuration::RESULT_MAX_COUNT }
    let(:results) do
      Discover::Results.new(entries: [], source: source, total_count: 0, results_url: nil)
    end

    it 'renders the no results message' do
      expect(rendered).to have_text I18n.t('discover.results.messages.no_results')
    end

    it 'does not render a link to all results' do
      within('turbo-frame') { expect(rendered).to have_no_selector('#libraries-results-button') }
    end
  end
end
