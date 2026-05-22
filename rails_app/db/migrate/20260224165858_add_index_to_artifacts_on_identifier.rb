# frozen_string_literal: true

# Have an index on identifier so we can use upsert
class AddIndexToArtifactsOnIdentifier < ActiveRecord::Migration[8.1]
  def change
    add_index :discover_artifacts, :identifier, unique: true
  end
end
