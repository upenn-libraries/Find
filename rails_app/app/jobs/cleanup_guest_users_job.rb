# frozen_string_literal: true

# Remove entries from the Users table for guest users of a certain age
class CleanupGuestUsersJob
  include Sidekiq::Job

  def perform
    age_in_days = Settings.cleanup.guest_users.days_old || 7
    batch_size = Settings.cleanup.guest_users.batch_size || 1000
    User.where('guest = ? and updated_at < ?', true, Time.current - age_in_days.to_i.days)
        .find_each(batch_size: batch_size, &:destroy)
  end
end
