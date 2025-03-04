# frozen_string_literal: true

module Discover
  # Represents an artwork scraped from the Penn Art Collection website.
  class ArtWork < ApplicationRecord
    self.table_name = 'discover_art_works'
    validates :title, presence: true
    validates :link, presence: true
  end
end
