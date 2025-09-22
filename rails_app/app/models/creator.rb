# frozen_string_literal: true

# Creator model from creator facet for use with entity extraction
class Creator < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    trigram: {
                      threshold: 0.3
                    }
                  }
  validates :name, presence: true, uniqueness: true
end
