# frozen_string_literal: true

module Discover
  module Parser
    # Parse Penn Museum CSV
    class PennMuseum < Base
      ARTIFACT_ATTRIBUTE_MAP = {
        title: :objectName,
        link: :'Record URL',
        identifier: :identifier,
        location: :curatorialSection,
        format: :material,
        creator: :creator,
        description: :description,
        on_display: :onDisplay,
        thumbnail: :thumbnail
      }.freeze
      BATCH_SIZE = 500

      class << self
        private

        # Parse given CSV into Artifacts.
        #
        # @param file [String] the input file path
        # @return [nil]
        def parse_tabular_data(file)
          CSV.foreach(file, headers: true).each_slice(BATCH_SIZE) do |rows|
            upsert_rows(rows)
          end
        end

        # Build attributes, validate and upsert a batch of rows.
        # Handle any row errors by ignoring the row and reporting.
        # @param rows [Array]
        # rubocop:disable Rails/SkipsModelValidations
        # @return [ActiveRecord::Result]
        def upsert_rows(rows)
          records = rows.each_with_object([]) do |row, acc|
            attributes = build_attributes(row)
            next unless valid_attributes?(attributes)

            acc << attributes
          rescue StandardError => e
            Honeybadger.notify(e)
            next
          end
          Artifact.upsert_all(records, unique_by: :index_discover_artifacts_on_identifier) if records.any?
        end
        # rubocop:enable Rails/SkipsModelValidations

        # Transforms the raw CSV data into model attributes
        # @param row [Hash]
        # @return [Hash{Symbol->String}]
        def build_attributes(row)
          ARTIFACT_ATTRIBUTE_MAP.transform_values do |csv_header|
            transform_value(csv_header.to_s, row)
          end
        end

        # Handles data hygiene (cleaning, casting, sanitizing, mapping)
        # @param csv_header [String] The CSV header name from our map (e.g. 'description')
        # @param row [Hash] The row from the CSV
        # @return [String, nil]
        def transform_value(csv_header, row)
          case csv_header
          when 'thumbnail'
            thumbnail_filename(row['identifier'])
          when 'description'
            sanitize(row[csv_header])
          when 'onDisplay'
            # Cast true/false strings to actual booleans
            ActiveModel::Type::Boolean.new.cast(row[csv_header])
          else
            row[csv_header].presence
          end
        end

        # Are the attributes sufficient to create a quality record? This stands in for AR validations since
        # we are using `upsert` here for efficiency.
        # @param attributes [Hash]
        # @return [Boolean]
        def valid_attributes?(attributes)
          attributes[:link].present? || attributes[:title].present?
        end

        # Generate a thumbnail filename for an identifier, provided the identifier has a mapped filename
        # base in our loaded mapper.
        # @param identifier [String]
        # @return [String]
        def thumbnail_filename(identifier)
          mapped = Mappings.museum_thumbnails[identifier]
          return if mapped.blank?

          "#{mapped}_300.jpg"
        end

        # Delete any records currently in the database that are not present in the file
        #
        # @param file [String] the input file path
        # @return frozen deleted record objects
        def delete_absent_records(file)
          existing_identifiers = Artifact.pluck :identifier
          incoming_identifiers = CSV.foreach(file, headers: true).collect { |row| row['identifier'] }
          absent_record_identifiers = existing_identifiers.difference(incoming_identifiers)
          Artifact.where(identifier: absent_record_identifiers).delete_all
        end
      end
    end
  end
end
