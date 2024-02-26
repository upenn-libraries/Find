# frozen_string_literal: true

# Prevent providers and uid's from storing null values
class AddConstraintsToUser < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :provider, false
    change_column_null :users, :uid, false
  end
end
