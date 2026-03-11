#  frozen_string_literal: true

module Discover
  class Record
    # Prepares Penn Museum record values for display
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

        "#{SECTION_MAP.fetch(section, section)} #{SECTION_TERM}"
      end

      # @return [String, nil]
      def formats
        join(record.formats.first)
      end

      # Return an AWS presigned URL to our S3 cache of Penn Museum thumbnails
      # @return [String]
      def thumbnail_url
        return nil if record.thumbnail.blank?

        s3 = Aws::S3::Resource.new
        obj = s3.bucket(Settings.discover.thumbnails.aws.bucket).object(record.thumbnail)
        obj.presigned_url(:get, expires_in: 300)
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
