# frozen_string_literal: true

# Rename the thumbnail_url column to better reflect usage
class ChangeArtifactThumbnailColumn < ActiveRecord::Migration[8.1]
  def change
    rename_column :discover_artifacts, :thumbnail_url, :thumbnail
  end
end
