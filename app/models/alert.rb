# frozen_string_literal: true

# Alert model
class Alert < ApplicationRecord
  validates :on, inclusion: [true, false]
  validates :text, presence: true
end
