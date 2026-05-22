# frozen_string_literal: true

class CreateArtWorks < ActiveRecord::Migration[7.2]
  def change
    create_table :discover_art_works do |t|
      t.string :title
      t.string :link
      t.string :thumbnail_url
      t.string :location
      t.string :format
      t.string :creator
      t.string :description

      t.timestamps
    end
  end
end
