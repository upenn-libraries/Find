# frozen_string_literal: true

describe DateMathBuilder do
  let(:date_math_builder) { described_class.new }

  describe '.recently_published' do
    it 'builds a solr date range query relative to the specified number of years' do
      expect(described_class.recently_published(5)).to eq('publication_date_sort: [NOW/YEAR-4YEAR TO *]')
    end
  end

  describe '.recently_added' do
    it 'builds a solr date range query relative to the current day' do
      expect(described_class.recently_added(30)).to eq('added_date_sort: [NOW/DAY-30DAY TO *]')
    end
  end
end
