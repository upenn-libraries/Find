# frozen_string_literal: true

# Remove some fields created during Blacklight installation that we won't ever need because
# we won't be using database-backed authentication
class CleanupUserTable < ActiveRecord::Migration[7.0]
  # NOTE: not reversible
  def change
    change_table :users, bulk: true do |t|
      t.remove :encrypted_password, type: :string
      t.remove :reset_password_token, type: :string
      t.remove :reset_password_sent_at, type: :datetime
      t.remove :remember_created_at, type: :datetime
      t.remove_index name: 'index_users_on_reset_password_token', if_exists: true
    end
  end
end
