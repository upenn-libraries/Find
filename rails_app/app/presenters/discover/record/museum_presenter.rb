#  frozen_string_literal: true

module Discover
  class Record
    # Prepares museum record values for display
    class MuseumPresenter < BasePresenter
      # @return [String, nil]
      def title
        record.title.first&.split('|')&.first&.strip
      end

      # @return [String, nil]
      def location
        record.title&.first&.split('|')&.last&.strip
      end
    end
  end
end
