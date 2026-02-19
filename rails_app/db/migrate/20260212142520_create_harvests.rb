# frozen_string_literal: true

class CreateHarvests < ActiveRecord::Migration[8.1]
  def change
    create_table :discover_harvests do |t|
      t.string :source, index: { unique: true }
      t.datetime :resource_last_modified
      t.string :etag

      t.timestamps
    end
  end
end
