# frozen_string_literal: true

module Discover
  # Represents an artwork scraped from the Penn Art Collection website.
  class ArtWork < ApplicationRecord
    include PgSearch::Model

    self.table_name = 'discover_art_works'
    validates :title, presence: true
    validates :link, presence: true

    # Configure search scope to return all artworks containing any word or partial word in the query
    pg_search_scope :search,
                    against: { creator: 'A', description: 'B', format: 'C', location: 'C', title: 'A' },
                    using: { tsearch: { any_word: true, prefix: true } }
  end
end
