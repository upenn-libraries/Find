# frozen_string_literal: true

describe Discover::LocationModalComponent, type: :components do
  let(:component) { described_class.new(source: source) }
  let(:rendered) { render_inline(component) }

  Discover::Configuration::SOURCES.each do |test_source|
    context "with source #{test_source}" do
      let(:source) { test_source }
      let(:presenter) { Discover::Results::ResultsPresenter.new(source: source) }

      it 'renders the modal with correct ID' do
        expect(rendered).to have_selector(".modal##{presenter.id}-location-modal")
      end

      it 'renders the modal title with source label' do
        expect(rendered).to have_selector(
          '.modal-title',
          text: I18n.t('discover.results.location_modal.title', source: presenter.label)
        )
      end

      it 'renders the modal body with content' do
        expect(rendered).to have_selector('.modal-body')
      end

      it 'renders the partial content dynamically' do
        expected_text = {
          find: 'Penn Libraries',
          finding_aids: "University of Pennsylvania's archives",
          museum: 'Penn Museum',
          art_collection: 'Penn Art Collection'
        }

        within('.modal-body') do
          expect(rendered).to have_text(expected_text[test_source])
        end
      end
    end
  end
end
