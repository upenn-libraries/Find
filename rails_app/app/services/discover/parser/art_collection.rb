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
          CSV.parse(data, col_sep: "\t", headers: true) do |row|
            artwork = ArtWork.find_or_initialize_by(identifier: row['identifier'])
            attributes = ARTWORK_ATTRIBUTES.index_with { |attr| row[attr.to_s] }
            artwork.assign_attributes(attributes)
            artwork.save! if artwork.new_record? || artwork.changed?
          end
        end
      end
    end
  end
end
