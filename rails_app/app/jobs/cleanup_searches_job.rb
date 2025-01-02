# frozen_string_literal: true

# Remove entries from the Searches table that are:
# - too old
# - old-ish and attached to a guest user
class CleanupSearchesJob
  include Sidekiq::Job

  def perform
    age_in_days = Settings.cleanup.searches.days_old || 7
    Search.delete_old_searches age_in_days
  end
end
