# frozen_string_literal: true

class AddItentifierToArtWorks < ActiveRecord::Migration[7.2]
  def change
    change_table :discover_art_works do |t|
      t.string :identifier
    end
  end
end
