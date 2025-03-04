# frozen_string_literal: true

class AddChecksumToArtWorks < ActiveRecord::Migration[7.2]
  def change
    add_column :discover_art_works, :checksum, :string
    add_index :discover_art_works, :checksum
  end
end
