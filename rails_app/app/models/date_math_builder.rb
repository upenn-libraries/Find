# frozen_string_literal: true

# Construct Solr date math query strings for date-based facets
class DateMathBuilder
  NOW = 'NOW'
  DAY = 'DAY'
  YEAR = 'YEAR'
  ADDED_DATE_SORT = 'added_date_sort'
  PUBLICATION_DATE_SORT = 'publication_date_sort'

  # @param days [Integer]
  # @return [String]
  def self.recently_added(days)
    new.recently_added(days)
  end

  # @param days [Integer]
  # @return [String]
  def self.recently_published(years)
    new.recently_published(years)
  end

  # @param days [Integer]
  # @return [String]
  def recently_added(days)
    build_query(field: ADDED_DATE_SORT, unit: DAY, offset: days)
  end

  # Subtracts one year because the current year is included in the recently published range.
  #
  # @param years [Integer]
  # @return [String]
  def recently_published(years)
    build_query(field: PUBLICATION_DATE_SORT, unit: YEAR, offset: years - 1)
  end

  private

  # @param field [Symbol, String]
  # @param unit [String]
  # @param offset [Integer]
  # @return [String]
  def build_query(field:, unit:, offset:)
    "#{field}: [#{range_start(unit, offset)} TO *]"
  end

  # @param unit [String]
  # @param offset [Integer]
  # @return [String]
  def range_start(unit, offset)
    "#{NOW}/#{unit}-#{offset}#{unit}"
  end
end
