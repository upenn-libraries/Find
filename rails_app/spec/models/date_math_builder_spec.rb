# frozen_string_literal: true

describe DateMathBuilder do
  let(:date_math_builder) { described_class.new }

  describe '.recently_added' do
    it 'builds a date range relative to the current day' do
      expect(date_math_builder.recently_added(30)).to eq('added_date_sort: [NOW/DAY-30DAY TO *]')
    end
  end

  describe '.recently_published' do
    it 'builds a date range relative to the specified number of years' do
      expect(date_math_builder.recently_published(5)).to eq('published_date_sort: [NOW/YEAR-4YEAR TO *]')
    end
  end
end
