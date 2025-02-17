#  frozen_string_literal: true

module Discover
  class Entry
    # Prepares museum entry values for display
    class MuseumPresenter < BasePresenter
      # @return [String]
      def title
        entry.title.first.split('|').first
      end

      # @return [String]
      def location
        entry.title.first.split('|').last
      end
    end
  end
end
