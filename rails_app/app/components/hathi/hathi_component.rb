# frozen_string_literal: true

module Hathi
  # Hathi link component
  class HathiComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :hathi_record

    def initialize(identifier_map:)
      @identifier_map = identifier_map
      @hathi_record = Hathi::Service.record(identifier_map: identifier_map)
    end

    # Helper method that extracts the link from the Hathi response
    # @return [String, nil]
    def link
      records = hathi_record['records']
      return if records.blank?

      record = records.values&.first
      record&.fetch('recordURL', nil)
    end

    # Render the component only if the record exists in HathiTrust, as indicated by the presence of the 'records' hash
    # @return [Boolean]
    def render?
      return false if hathi_record.blank?

      hathi_record['records'].present?
    end
  end
end
