# frozen_string_literal: true

module Discover
  # Represent an Entry worth of data - intended to provide a common schema for Sources
  class Entry
    attr_reader :title, :body, :identifiers, :link_url, :thumbnail_url

    # @param attributes [Hash] the attributes to create an entry with
    # @option attributes [Array<String>] :title
    # @option attributes [Hash{Symbol => Array<String>}] :body
    # @option attributes [Hash{Symbol => Array<String>}] :identifiers
    # @option attributes [String] :link_url
    # @option attributes [String, nil] :thumbnail_url
    def initialize(**attributes)
      @title = attributes.fetch(:title)
      @body = attributes.fetch(:body)
      @identifiers = attributes.fetch(:identifiers, {})
      @link_url = attributes.fetch(:link_url)
      @thumbnail_url = attributes.fetch(:thumbnail_url)
    end
  end
end
