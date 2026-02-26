#  frozen_string_literal: true

module Discover
  class Record
    # Prepares penn museum record values for display
    class PennMuseumPresenter < BasePresenter
      SECTION_TERM = 'Section'
      SECTION_MAP = {
        'Historic' => 'Historical Archaeology',
        'European' => 'European Archaeology'
      }.freeze

      # @return [String, nil]
      def title
        join(record.title.first)
      end

      # @return [String, nil]
      def location
        section = record.location.first
        return unless section

        "#{SECTION_MAP.fetch(location, location)} #{SECTION_TERM}"
      end

      # @return [String, nil]
      def formats
        join(record.formats.first)
      end

      private

      # @param comma_separated_terms [String]
      # @return [String, nil]
      def join(comma_separated_terms)
        return if comma_separated_terms.blank?

        comma_separated_terms.split(',').join(', ')
      end
    end
  end
end
