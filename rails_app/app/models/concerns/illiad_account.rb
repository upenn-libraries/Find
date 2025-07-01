# frozen_string_literal: true

# Concern centralizing logic that retrieves an Illiad user
module IlliadAccount
  extend ActiveSupport::Concern

  # @return [Illiad::User, FalseClass]
  def illiad_record
    @illiad_record ||= fetch_illiad_record
  end

  # Returns true if an illiad record is present for user.
  # @return [Boolean]
  def illiad_record?
    illiad_record.present?
  end

  # Books by Mail delivery address
  #
  # @return [Array<String>]
  def bbm_delivery_address
    return [] unless illiad_record?

    # Books by mail address is stored in two fields that should be joined. The data in Address2 is
    # usually formated like, 1 Smith St / Philadelphia, PA. We use the '/' to denote the break in the address.
    [illiad_record.data[:Address2], illiad_record.data[:Zip]].join(' ').split('/').compact_blank
  end

  # Office delivery address. This method does not check that the user is a FacultyExpress member
  # because that information is in the Alma record. If a user is not a FacultyExpress member this will most likely
  # return nil.
  #
  # We do our best here to extract the office delivery address. The Address field in Illiad is shared with the BBM
  # registration number and that's not always entered consistently.
  #
  # @return [String, nil]
  def office_delivery_address
    return unless illiad_record?

    address = illiad_record.data[:Address]

    return if address.blank?

    address.split('/')
           .reject { |part| part.match?('Books by Mail|BBM') } # Remove the Books by Mail registration number
           .compact_blank                                      # Remove any blank values
           .first
  end

  # Does the user have a blocked attribute?
  # @return [Boolean]
  def ill_blocked?
    illiad_record.data[:Cleared].in? Settings.illiad.blocked_user_values
  end

  private

  def fetch_illiad_record
    Illiad::User.find(id: uid)
  rescue Illiad::Client::Error
    false
  end
end
