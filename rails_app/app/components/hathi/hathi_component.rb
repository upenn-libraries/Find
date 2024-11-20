# frozen_string_literal: true

module Hathi
  # Hathi link component
  class HathiComponent < ViewComponent::Base
    attr_accessor :identifiers, :hathi_record

    def initialize(document:)
      @identifiers = document.identifiers
      @hathi_record = Hathi::Service.record(identifiers: identifiers)
    end

    # Helper method that extracts the link from the Hathi response
    def link
      records = hathi_record['records']
      return if records.blank?

      record = records.values&.first
      record&.fetch('recordURL', nil)
    end

    def exists_in_hathi?
      records = hathi_record['records']
      records.present?
    end

    def render?
      exists_in_hathi?
    end
  end
end
