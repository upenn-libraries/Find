# frozen_string_literal: true

class AddIlsGroupToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :ils_group
    end
  end
end
