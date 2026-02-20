#  frozen_string_literal: true

module Discover
  class Record
    # Prepares museum record values for display
    class MuseumPresenter < BasePresenter
      # @return [String, nil]
      def title
        record.title.first&.split('|')&.first&.strip
      end

      # @return [String, nil]
      def location
        record.title&.first&.split('|')&.last&.strip
      end

      def thumbnail_url
        # db_value = record.thumbnail_url
        db_value = '10002_300.jpg'
        return nil if db_value.blank?

        s3 = Aws::S3::Resource.new(
          region: Settings.discover.thumbnails.aws.region,
          credentials: Aws::Credentials.new(
            Settings.discover.thumbnails.aws.access_key,
            Settings.discover.thumbnails.aws.secret_access_key
          )
        )
        obj = s3.bucket(Settings.discover.thumbnails.aws.bucket).object(db_value)

        obj.presigned_url(:get, expires_in: 300)
      end
    end
  end
end
