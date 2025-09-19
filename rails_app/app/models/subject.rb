# frozen_string_literal: true

# A subject field value represented as an embedding
class Subject < ApplicationRecord
  has_neighbors :embedding
end
