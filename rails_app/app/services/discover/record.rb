# frozen_string_literal: true

module Discover
  # Represent a single returned record from a source
  class Record
    attr_reader :title, :identifiers, :link_url, :thumbnail_url

    # @param title [Array]
    # @param body [Hash]
    # @param identifiers [Hash]
    # @param link_url [String]
    # @param thumbnail_url [String, nil]
    def initialize(title:, body:, identifiers:, link_url:, thumbnail_url: nil)
      @title = title
      @body = body
      @identifiers = identifiers
      @link_url = link_url
      @thumbnail_url = thumbnail_url
    end

    def creator
      @body[:creator]
    end

    def formats
      @body[:format]
    end

    def location
      @body[:location]
    end

    def publication
      @body[:publication]
    end

    def description
      @body[:description]
    end
  end
end
