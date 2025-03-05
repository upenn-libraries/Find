# frozen_string_literal: true

require 'csv'

module Discover
  module Parser
    # Fetch and parse the scraped TSV
    class ArtCollection
      ARTWORK_ATTRIBUTES = %i[title link identifier thumbnail_url location format creator description].freeze

      class ParserError < StandardError; end

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
        # create new records if new rows exist, skip if not changed by generating checksum.
        #
        # @param data [String] the input file
        # @return [nil]
        def parse_tsv(data)
          CSV.parse(data, col_sep: "\t", headers: true) do |row|
            artwork = ArtWork.find_by(identifier: row['identifier'])
            checksum = Digest::SHA2.hexdigest(row.to_s)
            next unless artwork.nil? || artwork.checksum != checksum

            # Process both new and changed records
            update_or_create(artwork, row, checksum)
          end
        end

        # Updates an existing ArtWork or create a new one
        #
        # @param artwork [ArtWork, nil]
        # @param row [CSV::Row]
        # @param checksum [String]
        # @return [ArtWork]
        def update_or_create(artwork, row, checksum)
          attributes = ARTWORK_ATTRIBUTES.index_with { |attr|
            row[attr.to_s]
          }.merge(checksum: checksum)

          artwork ? artwork.update!(**attributes) : ArtWork.create!(**attributes)
        end
      end
    end
  end
end
