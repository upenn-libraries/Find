# frozen_string_literal: true

# Set up AWS resource config
# Used to render Discover Penn Museum thumbnails from S3 bucket
require 'aws-sdk-s3'

Aws.config.update(
  { region: Settings.discover.thumbnails.aws.region,
    credentials: Aws::Credentials.new(
      Settings.discover.thumbnails.aws.access_key,
      Settings.discover.thumbnails.aws.secret_access_key
    ) }
)
