# frozen_string_literal: true

# Alert model
class Alert < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  before_save :sanitize_text

  validates :on, inclusion: [true, false]
  validates :text, presence: true, if: :enabled?
  validate :maximum_alerts, on: :create

  ALLOWED_HTML_TAGS = %w[p a strong em ul ol li br].freeze

  private

  # @return [NilClass]
  def maximum_alerts
    errors.add(:base, 'Maximum alert count exceeded.') if Alert.count >= 2
  end

  # @return [TrueClass, FalseClass]
  def enabled?
    on == true
  end

  # Sanitize incoming HTML with a limited set of tags
  # @note This sanitation also happens on Drupal, as we want the user to see an error
  #   in the event that their text cannot save/display. This is an extra security measure
  #   to ensure clean data in our database.
  # @return [String]
  def sanitize_text
    self.text = sanitize(text, tags: ALLOWED_HTML_TAGS)
  end
end
