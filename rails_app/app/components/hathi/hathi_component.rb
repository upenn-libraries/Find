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

    # Don't render until we figure out how to display it and can mock it in the system specs
    def render?
      false
    end

    # Placeholder view logic to test that the link is extracting and displaying
    def call
      content_tag(:p) do
        link
      end
    end
  end
end
