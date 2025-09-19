# frozen_string_literal: true

class CreateSubjects < ActiveRecord::Migration[7.2]
  def change
    create_table :subjects do |t|
      t.string :content
      t.vector :embedding
      t.timestamps
    end
  end
end
