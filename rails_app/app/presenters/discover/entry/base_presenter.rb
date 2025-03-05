#  frozen_string_literal: true

module Discover
  class Entry
    # Prepares entry values for display
    class BasePresenter
      MAX_STRING_LENGTH = 255
      DISPLAY_TERMS = %i[title link_url thumbnail_url creator formats location publication description].freeze

      attr_reader :entry, :source

      delegate :link_url, :thumbnail_url, to: :entry

      # @param [Discover::Entry] entry
      # @param [String] source
      def initialize(entry:, source:)
        @entry = entry
        @source = source
      end

      # @return [String]
      def title
        entry.title.first
      end

      # @return [String, NilClass]
      def creator
        entry.body[:creator]&.join(', ')
      end

      # @return [String, NilClass]
      def formats
        entry.body[:format]&.join(', ')
      end

      # @return [String, NilClass]
      def location
        entry.body[:location]&.join(', ')
      end

      # @return [String, NilClass]
      def publication
        entry.body[:publication]&.join(', ')
      end

      # @return [String, NilClass]
      def description
        entry.body[:description]&.first&.truncate(MAX_STRING_LENGTH)
      end
    end
  end
end
