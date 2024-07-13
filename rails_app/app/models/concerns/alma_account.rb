# frozen_string_literal: true

# Concern centralizing logic that retrieves an Alma user and adds helper methods to check again the data provided in
# by Alma.
module AlmaAccount
  extend ActiveSupport::Concern

  LIBRARY_STAFF_GROUP = 'libr-staff'
  FACULTY_EXPRESS_GROUP = 'FacEXP'
  COURTESY_BORROWER_GROUP = 'courtesy'
  STUDENT_GROUPS = %w[undergrad graduate GIC].freeze

  # Returns true of a user's group is considered a "student" group
  # @return [Boolean]
  def student?
    STUDENT_GROUPS.include? ils_group
  end

  # Returns true if a user is in the Alma FaxEx group
  # @return [Boolean]
  def faculty_express?
    ils_group == FACULTY_EXPRESS_GROUP
  end

  # Return true if the user is a library staff
  # @return [Boolean]
  def library_staff?
    ils_group == LIBRARY_STAFF_GROUP
  end

  # Return true if the user is a courtesy_borrower
  def courtesy_borrower?
    ils_group == COURTESY_BORROWER_GROUP
  end

  # Returns User's full name in Alma
  # @return [String]
  def full_name
    return unless alma_record?

    alma_record.full_name
  end

  # @return [String, nil]
  def affiliation
    return unless alma_record?

    affiliation_stat = alma_record.user_statistic&.find do |stat|
      stat.dig('category_type', 'value') == 'AFFILIATION'
    end
    affiliation_stat&.dig 'statistic_category', 'desc'

  end

  # Display name for ILS group.
  # FIXME: If we are using a cached value for `ils_group`, there's a chance this value will not match the
  #        cached value (ie. if the user's group is changed after they login).
  # @return [String]
  def ils_group_name
    return unless alma_record?

    alma_record.user_group['desc']
  end

  # Returns true if an alma record is present for user.
  # @return [Boolean]
  def alma_record?
    alma_record.present?
  end

  # @return [Alma::User, FalseClass]
  def alma_record
    @alma_record ||= fetch_alma_record
  end

  private

  def fetch_alma_record
    Alma::User.find(uid)
  rescue Alma::User::ResponseError
    false
  end
end
