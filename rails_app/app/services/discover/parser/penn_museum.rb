# frozen_string_literal: true

require 'csv'

module Discover
  module Parser
    # Parse Penn Museum CSV
    class PennMuseum
      ARTIFACT_ATTRIBUTES = %i[title link identifier thumbnail_url
                               location format creator description
                               on_display].freeze

      ARTIFACT_ATTRIBUTE_MAP = {
        title: :objectName,
        link: :'Record URL',
        identifier: :identifier,
        # thumbnail_url: :tbd,
        location: :curatorialSection,
        format: :material,
        creator: :creator,
        description: :description,
        on_display: :onDisplay
      }.freeze

      # title = objectName OR title (maybe both?)
      # link = url
      # identifier = identifier
      # thumbnail_url = do we have the thumbnail urls?
      # location = not really sure? maybe on display instead?
      # format = material
      # creator = creator
      # description = description
      # onDisplay would be nice

      class << self
        # Import a given CSV to Objects
        #
        # @param file [String]
        # @return [nil]
        def import(file: csv_file)
          return unless file

          parse_csv(file)
        end

        private

        # Get CSV file body content from static location (for now)
        # TODO: do we want to pull this?
        #
        # @return [String, nil]
        def csv_file
          # file location (local?)
          'Penn_Museum_Collections_Data.csv'
        end

        # Parse given CSV into Artifacts.
        #
        # @param data [String] the input file content
        # @return [nil]
        def parse_csv(file)
          CSV.foreach(file, headers: true).each_with_index do |row, index|
            # for testing - we can remove this later
            break if index >= 100

            process_row(row)
          rescue StandardError => e
            Honeybadger.notify(e)
            next
          end
        end

        # Process CSV row
        def process_row(row)
          artifact = find_or_initialize_artifact(row)
          attributes = build_attributes(row)
          artifact.update!(attributes)
        end

        # Find/create new artifact
        def find_or_initialize_artifact(row)
          url_header = ARTIFACT_ATTRIBUTE_MAP[:link].to_s
          Artifact.find_or_initialize_by(link: row[url_header])
        end

        # Transforms the raw CSV data into model attributes.
        def build_attributes(row)
          ARTIFACT_ATTRIBUTE_MAP.transform_values do |csv_header|
            raw_value = row[csv_header.to_s]
            transform_value(csv_header, raw_value)
          end
        end

        # Handles data hygiene (cleaning, casting, sanitizing)
        # @param csv_header [Symbol] The CSV header name from our map (e.g., :description)
        # @param value [String] The raw value from the CSV row
        def transform_value(csv_header, value)
          case csv_header
          when :description
            sanitize(value)
          when :onDisplay
            # Cast "true"/"false" strings to actual booleans
            ActiveModel::Type::Boolean.new.cast(value)
          else
            value.presence
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
