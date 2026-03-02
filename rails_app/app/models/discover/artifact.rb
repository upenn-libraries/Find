# frozen_string_literal: true

module Discover
  # Represents an artwork scraped from the Penn Art Collection website.
  class Artifact < ApplicationRecord
    include PgSearch::Model

    self.table_name = 'discover_artifacts'
    validates :title, presence: true
    validates :link, presence: true

    # Configure search scope to return all artifacts containing any word or partial word in the query
    pg_search_scope :search,
                    against: :search_vector,
                    using: { tsearch: { any_word: true, prefix: true, tsvector_column: 'search_vector',
                                        dictionary: 'english' } },
                    order_within_rank: 'discover_artifacts.on_display DESC'
  end
end
