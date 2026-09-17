# frozen_string_literal: true

module Discover
  module Parser
    # Fetch and parse the scraped TSV
    class ArtCollection < Base
      ARTWORK_ATTRIBUTES = %i[title link identifier thumbnail_url location format creator description].freeze

      class << self
        private

        # Parse given TSV into ArtWorks.
        #
        # @param data [String] the input file
        # @return [nil]
        def parse_tabular_data(data)
          ArtWork.transaction do
            ActiveRecord::Base.connection.truncate(ArtWork.table_name)

            CSV.parse(data, col_sep: "\t", headers: true, quote_char: nil) do |row|
              attributes = ARTWORK_ATTRIBUTES.index_with do |attr|
                attr == :description ? sanitize(row[attr.to_s]) : row[attr.to_s]
              end
              ArtWork.new(attributes).save!
            rescue StandardError => e
              Honeybadger.notify(e)
              next
            end
          end
        rescue StandardError => e
          Honeybadger.notify(e)
        end
      end
    end
  end
end
