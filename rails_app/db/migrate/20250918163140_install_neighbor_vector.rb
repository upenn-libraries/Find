# frozen_string_literal: true

class InstallNeighborVector < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'vector'
  end
end
