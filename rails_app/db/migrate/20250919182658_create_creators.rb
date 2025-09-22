# frozen_string_literal: true

class CreateCreators < ActiveRecord::Migration[7.2]
  def change
    create_table :creators do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :creators, :name, unique: true
  end
end
