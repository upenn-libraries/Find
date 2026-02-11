# frozen_string_literal: true

describe Discover::RecordComponent, type: :components do
  let(:component) { described_class.new(record: record, source: nil) }
  let(:rendered) { render_inline(component) }

  context 'with a robust entry' do
    let(:record) { build(:discover_record) }
    let(:record_presenter) { Discover::Record::BasePresenter.new(record: record) }

    it 'displays location data' do
      expect(rendered).to have_text record_presenter.location
    end

    it 'displays creator data' do
      expect(rendered).to have_text record_presenter.creator
    end

    it 'displays publication data' do
      expect(rendered).to have_text record_presenter.publication
    end

    it 'displays format data' do
      expect(rendered).to have_text record_presenter.formats
    end

    it 'displays link to record' do
      expect(rendered).to have_link record_presenter.title, href: record_presenter.link_url, exact: true
    end

    it 'does not render a thumbnail' do
      expect(rendered).to have_no_selector '.results-list-item__thumbnail'
    end
  end

  context 'with a thumbnail' do
    let(:record) { build(:discover_record, :with_thumbnail) }
    let(:record_presenter) { Discover::Record::BasePresenter.new(record: record) }

    it 'renders a thumbnail' do
      expect(rendered).to have_selector("img[src*='#{record_presenter.thumbnail_url}']")
    end
  end

  context 'with a museum entry' do
    let(:record) { build(:discover_record, :from_museum) }
    let(:record_presenter) { Discover::Record::MuseumPresenter.new(record: record) }

    it 'renders the title' do
      expect(rendered).to have_text record_presenter.title
    end

    it 'renders the location' do
      expect(rendered).to have_text record_presenter.location
    end
  end
end
