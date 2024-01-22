# frozen_string_literal: true

class AddProviderToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      # omniauthable
      t.string :provider
      t.string :uid

      t.index %i[uid provider], unique: true
    end
  end
end
