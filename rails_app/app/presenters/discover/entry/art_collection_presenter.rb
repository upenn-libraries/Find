# frozen_string_literal: true

#  frozen_string_literal: true

module Discover
  class Entry
    # Prepares art collection entry values for display
    class ArtCollectionPresenter < BasePresenter
      # @return [String]
      def title
        entry.title.first.split(/[-|–—]/, 2).first.strip
      end
    end
  end
end
