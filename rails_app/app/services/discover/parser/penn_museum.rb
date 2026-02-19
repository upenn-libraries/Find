# frozen_string_literal: true

module Discover
  module Parser
    # Parse Penn Museum CSV
    class PennMuseum < Base
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

      class << self
        private

        # Parse given CSV into Artifacts.
        #
        # @param file [String] the input file path
        # @return [nil]
        def parse_tabular_data(file)
          CSV.foreach(file, headers: true) do |row|
            artifact = find_or_initialize_artifact(row)
            attributes = build_attributes(row)
            artifact.update!(attributes)
          rescue StandardError => e
            Honeybadger.notify(e)
            next
          end
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
            # Cast true/false strings to actual booleans
            ActiveModel::Type::Boolean.new.cast(value)
          else
            value.presence
          end
        end
      end
    end
  end
end
