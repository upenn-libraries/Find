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
                    against: %i[creator description format location title],
                    using: { tsearch: { any_word: true, prefix: true } },
                    # TODO: is this the best way to sort? descending with "true" values at the top?
                    order_within_rank: 'discover_artifacts.on_display DESC'
  end
end
