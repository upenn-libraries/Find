#  frozen_string_literal: true

module Discover
  class Record
    # Prepares record values for display
    class BasePresenter
      MAX_STRING_LENGTH = 255
      DISPLAY_TERMS = %i[title link_url thumbnail_url creator formats location publication description].freeze

      attr_reader :record

      # @param [HaDiscover::Record] record
      def initialize(record:)
        @record = record
      end

      # @return [String]
      def title
        record.title.first
      end

      # @return [String, NilClass]
      def creator
        record.creator&.join(', ')
      end

      # @return [String, NilClass]
      def formats
        record.formats&.join(', ')
      end

      # @return [String, NilClass]
      def location
        record.location&.join(', ')
      end

      # @return [String, NilClass]
      def publication
        record.publication&.join(', ')
      end

      # @return [String, NilClass]
      def description
        record.description&.first&.truncate(MAX_STRING_LENGTH)
      end

      # @return [String, NilClass]
      delegate :link_url, to: :record

      # @return [String, NilClass]
      delegate :thumbnail_url, to: :record
    end
  end
end
