# frozen_string_literal: true

module IlliadUser
  extend ActiveSupport::Concern

  # @return [Illiad::User, FalseClass]
  def illiad_record
    @illiad_record ||= begin
                         Illiad::User.find(id: uid)
                       rescue Illiad::Client::Error
                         false
                       end
  end
end
