# frozen_string_literal: true

# Remove entries from the Searches table that are:
# - without a linked user_id
# - older than a certain number of days
class CleanupSearchesJob
  include Sidekiq::Job

  sidekiq_options queue: 'low'

  def perform
    age_in_days = Settings.cleanup.searches.days_old || 7
    Search.delete_old_searches age_in_days
  end
end
