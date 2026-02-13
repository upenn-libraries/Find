# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
class CreateArtifacts < ActiveRecord::Migration[7.2]
  def change
    create_table :discover_artifacts do |t|
      t.string :title
      t.string :link
      t.string :identifier
      t.string :thumbnail_url
      t.string :location
      t.string :format
      t.string :creator
      t.string :description
      t.boolean :on_display
      t.string :other_values, array: true, default: []

      t.timestamps
    end
  end
end
# rubocop:enable Metrics/MethodLength
