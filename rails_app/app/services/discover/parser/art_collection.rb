# frozen_string_literal: true

require 'csv'

module Discover
  module Parser
    # Fetch and parse the scraped TSV
    class ArtCollection
      ARTWORK_ATTRIBUTES = %i[title link identifier thumbnail_url location format creator description].freeze

      class << self
        # Import a given TSV to ArtWorks (default: TSV from server)
        #
        # @param file [String]
        # @return [nil]
        def import(file: tsv_file)
          return unless file

          parse_tsv(file)
        end

        private

        # Get TSV file body content from HTTP location
        #
        # @return [String, nil]
        def tsv_file
          Faraday.get(Settings.discover.source.art_collection.tsv_path)&.body
        end

        # Parse given TSV into ArtWorks. Update existing records if they have changed,
        # create new records if new rows exist, skip if unchanged.
        #
        # @param data [String] the input file
        # @return [nil]
        def parse_tsv(data)
          CSV.parse(data, col_sep: "\t", headers: true, quote_char: nil) do |row|
            artwork = ArtWork.find_or_initialize_by(link: row['link'])
            attributes = ARTWORK_ATTRIBUTES.index_with do |attr|
              attr == :description ? sanitize(row[attr.to_s]) : row[attr.to_s]
            end
            artwork.tap { |a| a.attributes = attributes }.save!
          rescue StandardError => e
            Honeybadger.notify(e)
            next
          end
        end

        # Sanitize string with HTML tags
        #
        # @param description [String]
        # @return [String, nil]
        def sanitize(description)
          ActionView::Base.full_sanitizer.sanitize(description)&.gsub(/[Ââ]/, '')&.gsub('&nbsp;', ' ')
        end
      end
    end
  end
end
