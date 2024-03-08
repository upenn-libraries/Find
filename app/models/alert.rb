# frozen_string_literal: true

# Alert model
class Alert < ApplicationRecord
  validates :on, inclusion: [true, false]
  validates :text, presence: true
  validate :maximum_alerts, on: :create

  def maximum_alerts
    errors.add(:base, 'Maxiumum alert count exceeded.') if Alert.count >= 2
  end
end
