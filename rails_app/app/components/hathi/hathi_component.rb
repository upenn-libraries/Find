# frozen_string_literal: true

module Hathi
  # Hathi link component
  class HathiComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :identifier_map, :hathi_record

    def initialize(document:)
      @identifier_map = document.identifier_map
      @hathi_record = Hathi::Service.record(identifier_map: identifier_map)
    end

    # Helper method that extracts the link from the Hathi response
    # @return [String]
    def link
      records = hathi_record['records']
      return if records.blank?

      record = records.values&.first
      record&.fetch('recordURL', nil)
    end

    # @return [TrueClass, FalseClass]
    def exists_in_hathi?
      records = hathi_record['records']
      records.present?
    end

    # @return [TrueClass, FalseClass]
    def render?
      exists_in_hathi?
    end
  end
end
