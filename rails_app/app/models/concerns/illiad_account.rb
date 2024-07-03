# frozen_string_literal: true

# Concern centralizing logic that retrieves an Illiad user
module IlliadAccount
  extend ActiveSupport::Concern

  # @return [Illiad::User, FalseClass]
  def illiad_record
    @illiad_record ||= fetch_illiad_record
  end

  private

  def fetch_illiad_record
    Illiad::User.find(id: uid)
  rescue Illiad::Client::Error
    false
  end
end
